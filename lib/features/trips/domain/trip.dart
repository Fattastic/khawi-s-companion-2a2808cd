enum TripStatus { planned, active, completed, cancelled }

class TripWaypoint {
  final double lat;
  final double lng;
  final String label;

  const TripWaypoint({
    required this.lat,
    required this.lng,
    required this.label,
  });

  factory TripWaypoint.fromJson(Map<String, dynamic> j) => TripWaypoint(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        label: (j['label'] as String?) ?? 'Stop',
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'label': label,
      };
}

TripStatus tripStatusFromString(String v) {
  switch (v) {
    case 'active':
      return TripStatus.active;
    case 'completed':
      return TripStatus.completed;
    case 'cancelled':
      return TripStatus.cancelled;
    default:
      return TripStatus.planned;
  }
}

String tripStatusToString(TripStatus s) {
  switch (s) {
    case TripStatus.planned:
      return 'planned';
    case TripStatus.active:
      return 'active';
    case TripStatus.completed:
      return 'completed';
    case TripStatus.cancelled:
      return 'cancelled';
  }
}

class Trip {
  final String id;
  final String driverId;

  final double originLat, originLng, destLat, destLng;
  final String? originLabel, destLabel;
  final String? polyline;
  final DateTime departureTime;
  final List<TripWaypoint> waypoints;

  final bool isRecurring;
  final Map<String, dynamic>? scheduleJson;

  final int seatsTotal;
  final int seatsAvailable;

  final bool womenOnly;
  final bool isKidsRide;

  final List<String> tags;
  final TripStatus status;
  final String? neighborhoodId;

  // Module A
  final int? matchScore; // 0-100
  final double? acceptProb; // 0-1
  final List<String>? matchTags; // max 3

  // Module D (optional, used by marketplace UI)
  final int? driverTrustScore; // 0-100
  final String? driverTrustBadge; // bronze/silver/gold
  final bool? driverJuniorTrusted; // for Junior

  // Module I: ETA Estimation
  final int? etaMinutes; // computed/cached ETA

  // Distance & environmental impact
  final double? distanceKm; // computed trip distance
  final double? co2SavedKg; // environmental impact

  const Trip({
    required this.id,
    required this.driverId,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.departureTime,
    this.waypoints = const [],
    required this.isRecurring,
    required this.seatsTotal,
    required this.seatsAvailable,
    required this.womenOnly,
    required this.isKidsRide,
    required this.tags,
    required this.status,
    this.originLabel,
    this.destLabel,
    this.polyline,
    this.scheduleJson,
    this.neighborhoodId,
    this.matchScore,
    this.acceptProb,
    this.matchTags,
    this.driverTrustScore,
    this.driverTrustBadge,
    this.driverJuniorTrusted,
    this.etaMinutes,
    this.distanceKm,
    this.co2SavedKg,
  });

  factory Trip.fromJson(Map<String, dynamic> j) {
    final schedule = (j['schedule_json'] as Map?)?.cast<String, dynamic>();
    final rawWaypoints =
        (j['waypoints'] as List?) ?? (schedule?['waypoints'] as List?);

    return Trip(
      id: j['id'] as String,
      driverId: j['driver_id'] as String,
      originLat: (j['origin_lat'] as num).toDouble(),
      originLng: (j['origin_lng'] as num).toDouble(),
      destLat: (j['dest_lat'] as num).toDouble(),
      destLng: (j['dest_lng'] as num).toDouble(),
      originLabel: j['origin_label'] as String?,
      destLabel: j['dest_label'] as String?,
      polyline: j['polyline'] as String?,
      departureTime: DateTime.parse(j['departure_time'] as String),
      waypoints: rawWaypoints == null
          ? const []
          : rawWaypoints
              .map((e) =>
                  TripWaypoint.fromJson((e as Map).cast<String, dynamic>()),)
              .toList(),
      isRecurring: (j['is_recurring'] as bool?) ?? false,
      scheduleJson: schedule,
      seatsTotal: (j['seats_total'] as int?) ?? 0,
      seatsAvailable: (j['seats_available'] as int?) ?? 0,
      womenOnly: (j['women_only'] as bool?) ?? false,
      isKidsRide: (j['is_kids_ride'] as bool?) ?? false,
      tags: ((j['tags'] as List?) ?? const []).cast<String>(),
      status: tripStatusFromString((j['status'] as String?) ?? 'planned'),
      neighborhoodId: j['neighborhood_id'] as String?,
      matchScore: (j['match_score'] as num?)?.toInt(),
      acceptProb: (j['accept_prob'] as num?)?.toDouble(),
      matchTags: (j['explanation_tags'] as List?)?.cast<String>(),
      driverTrustScore: (j['driver_trust_score'] as num?)?.toInt(),
      driverTrustBadge: j['driver_trust_badge'] as String?,
      driverJuniorTrusted: j['driver_junior_trusted'] as bool?,
      etaMinutes: (j['eta_minutes'] as num?)?.toInt(),
      distanceKm: (j['distance_km'] as num?)?.toDouble(),
      co2SavedKg: (j['co2_saved_kg'] as num?)?.toDouble(),
    );
  }

  /// JSON shape suitable for inserting/updating the `trips` table.
  /// This intentionally excludes computed/derived fields (AI match, trust, etc).
  Map<String, dynamic> toDbJson() {
    final schedule = <String, dynamic>{...?scheduleJson};
    if (waypoints.isNotEmpty) {
      schedule['waypoints'] = waypoints.map((w) => w.toJson()).toList();
    }

    final m = <String, dynamic>{
      'driver_id': driverId,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'origin_label': originLabel,
      'dest_label': destLabel,
      'polyline': polyline,
      'departure_time': departureTime.toIso8601String(),
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
      'is_recurring': isRecurring,
      'schedule_json': schedule,
      'seats_total': seatsTotal,
      'seats_available': seatsAvailable,
      'women_only': womenOnly,
      'is_kids_ride': isKidsRide,
      'tags': tags,
      'status': tripStatusToString(status),
      'neighborhood_id': neighborhoodId,
      'eta_minutes': etaMinutes,
      'distance_km': distanceKm,
      'co2_saved_kg': co2SavedKg,
    };
    if (id.isNotEmpty) {
      m['id'] = id;
    }
    return m;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'driver_id': driverId,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
        'origin_label': originLabel,
        'dest_label': destLabel,
        'polyline': polyline,
        'departure_time': departureTime.toIso8601String(),
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'is_recurring': isRecurring,
        'schedule_json': scheduleJson,
        'seats_total': seatsTotal,
        'seats_available': seatsAvailable,
        'women_only': womenOnly,
        'is_kids_ride': isKidsRide,
        'tags': tags,
        'status': tripStatusToString(status),
        'neighborhood_id': neighborhoodId,
        'match_score': matchScore,
        'accept_prob': acceptProb,
        'explanation_tags': matchTags,
        'driver_trust_score': driverTrustScore,
        'driver_trust_badge': driverTrustBadge,
        'driver_junior_trusted': driverJuniorTrusted,
        'eta_minutes': etaMinutes,
        'distance_km': distanceKm,
        'co2_saved_kg': co2SavedKg,
      };

  Trip copyWith({
    String? id,
    String? driverId,
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    String? originLabel,
    String? destLabel,
    String? polyline,
    DateTime? departureTime,
    List<TripWaypoint>? waypoints,
    bool? isRecurring,
    Map<String, dynamic>? scheduleJson,
    int? seatsTotal,
    int? seatsAvailable,
    bool? womenOnly,
    bool? isKidsRide,
    List<String>? tags,
    TripStatus? status,
    String? neighborhoodId,
    int? matchScore,
    double? acceptProb,
    List<String>? matchTags,
    int? driverTrustScore,
    String? driverTrustBadge,
    bool? driverJuniorTrusted,
    int? etaMinutes,
    double? distanceKm,
    double? co2SavedKg,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      originLabel: originLabel ?? this.originLabel,
      destLabel: destLabel ?? this.destLabel,
      polyline: polyline ?? this.polyline,
      departureTime: departureTime ?? this.departureTime,
      waypoints: waypoints ?? this.waypoints,
      isRecurring: isRecurring ?? this.isRecurring,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      womenOnly: womenOnly ?? this.womenOnly,
      isKidsRide: isKidsRide ?? this.isKidsRide,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
      matchScore: matchScore ?? this.matchScore,
      acceptProb: acceptProb ?? this.acceptProb,
      matchTags: matchTags ?? this.matchTags,
      driverTrustScore: driverTrustScore ?? this.driverTrustScore,
      driverTrustBadge: driverTrustBadge ?? this.driverTrustBadge,
      driverJuniorTrusted: driverJuniorTrusted ?? this.driverJuniorTrusted,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
    );
  }
}
