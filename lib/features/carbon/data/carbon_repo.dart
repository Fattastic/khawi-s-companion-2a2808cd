import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/features/carbon/domain/carbon_summary.dart';

class CarbonRepo {
  CarbonRepo(this._client);

  final SupabaseClient _client;

  Future<CarbonSummary> fetchMySummary({int limit = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return CarbonSummary.empty;

    try {
      final rows = await _client
          .from('trip_requests')
          .select('''
            trip_id,
            created_at,
            trips!inner (
              departure_time,
              origin_label,
              dest_label,
              distance_km,
              co2_saved_kg
            )
          ''')
          .or('passenger_id.eq.$userId,driver_id.eq.$userId')
          .inFilter('status', ['completed', 'dropped_off'])
          .order('created_at', ascending: false)
          .limit(limit);

      final impacts = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(_mapImpact)
          .whereType<CarbonTripImpact>()
          .toList(growable: false);

      return summarizeCarbonTrips(impacts);
    } catch (_) {
      return CarbonSummary.empty;
    }
  }

  CarbonTripImpact? _mapImpact(Map<String, dynamic> row) {
    final trip = row['trips'] as Map<String, dynamic>?;
    if (trip == null) return null;

    final co2SavedKg = (trip['co2_saved_kg'] as num?)?.toDouble() ?? 0;
    if (co2SavedKg <= 0) return null;

    final departureText =
        (trip['departure_time'] ?? row['created_at'])?.toString();
    final departureTime = DateTime.tryParse(departureText ?? '');
    if (departureTime == null) return null;

    return CarbonTripImpact(
      tripId: (row['trip_id'] ?? '').toString(),
      departureTime: departureTime,
      originLabel: trip['origin_label'] as String?,
      destLabel: trip['dest_label'] as String?,
      co2SavedKg: co2SavedKg,
      distanceKm: (trip['distance_km'] as num?)?.toDouble(),
    );
  }
}
