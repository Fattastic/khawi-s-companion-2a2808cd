import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/network/retry_utils.dart';

import '../domain/ride_history_entry.dart';

/// Repository for fetching completed ride history.
///
/// Uses Supabase views joining trips + trip_requests + profiles for
/// a unified ride history feed.
class RideHistoryRepo {
  final SupabaseClient _client;

  RideHistoryRepo(this._client);

  /// Fetch paginated ride history for a user (as passenger or driver).
  ///
  /// Returns completed trips with counterpart info and ratings.
  Future<List<RideHistoryEntry>> fetchHistory({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    // Query trip_requests joined with trips and profiles
    final response = await RetryUtils.retry(
      () => _client
          .from('trip_requests')
          .select('''
          id,
          trip_id,
          passenger_id,
          driver_id,
          status,
          created_at,
          rating_given,
          rating_received,
          trips!inner (
            origin_lat,
            origin_lng,
            dest_lat,
            dest_lng,
            origin_label,
            dest_label,
            departure_time,
            distance_km,
            co2_saved_kg,
            waypoints,
            schedule_json
          )
        ''')
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .inFilter('status', ['completed', 'dropped_off'])
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1),
      retryIf: RetryUtils.shouldRetrySupabaseError,
    );

    return (response as List)
        .map(
          (row) => _mapToHistoryEntry(
            row as Map<String, dynamic>,
            userId,
          ),
        )
        .toList();
  }

  /// Get ride history count for a user.
  Future<int> fetchHistoryCount(String userId) async {
    final response = await RetryUtils.retry(
      () => _client
          .from('trip_requests')
          .select('id')
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .inFilter('status', ['completed', 'dropped_off']),
      retryIf: RetryUtils.shouldRetrySupabaseError,
    );
    return (response as List).length;
  }

  RideHistoryEntry _mapToHistoryEntry(
    Map<String, dynamic> row,
    String userId,
  ) {
    final trip = row['trips'] as Map<String, dynamic>? ?? {};
    final scheduleJson = trip['schedule_json'] as Map<String, dynamic>?;
    final rawWaypoints =
        (trip['waypoints'] as List?) ?? (scheduleJson?['waypoints'] as List?);

    final waypointLabels = rawWaypoints == null
        ? const <String>[]
        : rawWaypoints
            .whereType<Map<String, dynamic>>()
            .map((w) => (w['label'] as String?)?.trim())
            .whereType<String>()
            .where((label) => label.isNotEmpty)
            .toList();

    return RideHistoryEntry(
      tripId: row['trip_id'] as String,
      requestId: row['id'] as String,
      originLabel: trip['origin_label'] as String?,
      destLabel: trip['dest_label'] as String?,
      originLat: (trip['origin_lat'] as num?)?.toDouble() ?? 0,
      originLng: (trip['origin_lng'] as num?)?.toDouble() ?? 0,
      destLat: (trip['dest_lat'] as num?)?.toDouble() ?? 0,
      destLng: (trip['dest_lng'] as num?)?.toDouble() ?? 0,
      waypointLabels: waypointLabels,
      departureTime: DateTime.parse(
        trip['departure_time'] as String? ?? DateTime.now().toIso8601String(),
      ),
      completedAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
      counterpartName: _counterpartName(row, userId),
      ratingGiven: row['rating_given'] as int?,
      ratingReceived: row['rating_received'] as int?,
      status: row['status'] as String? ?? 'completed',
      distanceKm: (trip['distance_km'] as num?)?.toDouble(),
      co2SavedKg: (trip['co2_saved_kg'] as num?)?.toDouble(),
      xpEarned: 45,
    );
  }

  String _counterpartName(Map<String, dynamic> row, String userId) {
    final passengerId = row['passenger_id'] as String?;
    final driverId = row['driver_id'] as String?;
    final counterpartId = passengerId == userId ? driverId : passengerId;

    if (counterpartId == null || counterpartId.isEmpty) {
      return 'Khawi User';
    }

    final short = counterpartId.length <= 6
        ? counterpartId
        : counterpartId.substring(0, 6);
    return 'User $short';
  }
}
