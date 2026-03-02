/// Ride history model combining trip and request data for display.
///
/// Provides a unified view of completed rides for both drivers and passengers.
class RideHistoryEntry {
  final String tripId;
  final String requestId;

  /// Origin/destination labels.
  final String? originLabel;
  final String? destLabel;

  /// Coordinates for map thumbnail.
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;

  /// Intermediate stops (if trip was multi-stop).
  final List<String> waypointLabels;

  /// Trip timing.
  final DateTime departureTime;
  final DateTime? completedAt;

  /// Counterpart info (driver for passengers, passenger for drivers).
  final String? counterpartName;
  final String? counterpartAvatarUrl;

  /// Rating given for this trip (null if not yet rated).
  final int? ratingGiven;
  final int? ratingReceived;

  /// Trip status.
  final String status;

  /// Distance and environmental impact.
  final double? distanceKm;
  final double? co2SavedKg;

  /// XP earned from this trip.
  final int? xpEarned;

  const RideHistoryEntry({
    required this.tripId,
    required this.requestId,
    this.originLabel,
    this.destLabel,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.waypointLabels = const [],
    required this.departureTime,
    this.completedAt,
    this.counterpartName,
    this.counterpartAvatarUrl,
    this.ratingGiven,
    this.ratingReceived,
    required this.status,
    this.distanceKm,
    this.co2SavedKg,
    this.xpEarned,
  });

  /// Whether a rating can still be submitted for this ride.
  bool get canRate => status == 'completed' && ratingGiven == null;

  /// Whether this trip has been completed.
  bool get isCompleted => status == 'completed';

  /// Formatted date for display.
  String get formattedDate {
    final d = departureTime;
    return '${d.day}/${d.month}/${d.year}';
  }

  /// Formatted time for display.
  String get formattedTime {
    final d = departureTime;
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  factory RideHistoryEntry.fromJson(Map<String, dynamic> j) => RideHistoryEntry(
        tripId: j['trip_id'] as String,
        requestId: j['request_id'] as String,
        originLabel: j['origin_label'] as String?,
        destLabel: j['dest_label'] as String?,
        originLat: (j['origin_lat'] as num).toDouble(),
        originLng: (j['origin_lng'] as num).toDouble(),
        destLat: (j['dest_lat'] as num).toDouble(),
        destLng: (j['dest_lng'] as num).toDouble(),
        waypointLabels: ((j['waypoint_labels'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        departureTime: DateTime.parse(j['departure_time'] as String),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String)
            : null,
        counterpartName: j['counterpart_name'] as String?,
        counterpartAvatarUrl: j['counterpart_avatar_url'] as String?,
        ratingGiven: j['rating_given'] as int?,
        ratingReceived: j['rating_received'] as int?,
        status: (j['status'] as String?) ?? 'completed',
        distanceKm: (j['distance_km'] as num?)?.toDouble(),
        co2SavedKg: (j['co2_saved_kg'] as num?)?.toDouble(),
        xpEarned: j['xp_earned'] as int?,
      );
}
