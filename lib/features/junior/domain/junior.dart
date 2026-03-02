class Kid {
  final String id, parentId, name;
  final String? avatarUrl, schoolName, notes;
  final int? age;
  const Kid({
    required this.id,
    required this.parentId,
    required this.name,
    this.avatarUrl,
    this.schoolName,
    this.notes,
    this.age,
  });
  factory Kid.fromJson(Map<String, dynamic> j) => Kid(
        id: j['id'] as String,
        parentId: j['parent_id'] as String,
        name: (j['name'] as String?) ?? '',
        avatarUrl: j['avatar_url'] as String?,
        schoolName: j['school_name'] as String?,
        notes: j['notes'] as String?,
        age: (j['age'] as num?)?.toInt(),
      );
}

class JuniorRun {
  final String id, kidId, parentId;
  final String? assignedDriverId, tripId;
  final String status; // keep string for exact DB values
  final double pickupLat, pickupLng, dropoffLat, dropoffLng;
  final DateTime pickupTime;

  const JuniorRun({
    required this.id,
    required this.kidId,
    required this.parentId,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.pickupTime,
    this.assignedDriverId,
    this.tripId,
  });

  bool isAuthorizedBy(String userId) => userId == parentId;

  factory JuniorRun.fromJson(Map<String, dynamic> j) => JuniorRun(
        id: j['id'] as String,
        kidId: j['kid_id'] as String,
        parentId: j['parent_id'] as String,
        assignedDriverId: j['assigned_driver_id'] as String?,
        status: (j['status'] as String?) ?? 'planned',
        pickupLat: (j['pickup_lat'] as num).toDouble(),
        pickupLng: (j['pickup_lng'] as num).toDouble(),
        dropoffLat: (j['dropoff_lat'] as num).toDouble(),
        dropoffLng: (j['dropoff_lng'] as num).toDouble(),
        pickupTime: DateTime.parse(j['pickup_time'] as String),
        tripId: j['trip_id'] as String?,
      );
}

class JuniorRunEvent {
  final String id, runId, actorId, actorRole, eventType;
  final String? prevStatus, newStatus;
  final double? lat, lng;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;

  const JuniorRunEvent({
    required this.id,
    required this.runId,
    required this.actorId,
    required this.actorRole,
    required this.eventType,
    required this.createdAt,
    this.prevStatus,
    this.newStatus,
    this.lat,
    this.lng,
    this.meta,
  });

  factory JuniorRunEvent.fromJson(Map<String, dynamic> j) => JuniorRunEvent(
        id: j['id'] as String,
        runId: j['run_id'] as String,
        actorId: j['actor_id'] as String,
        actorRole: j['actor_role'] as String,
        eventType: j['event_type'] as String,
        prevStatus: j['prev_status'] as String?,
        newStatus: j['new_status'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        meta: (j['meta'] as Map?)?.cast<String, dynamic>(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class SosEvent {
  final String id;
  final String? runId, tripId, parentId, driverId;
  final String triggeredBy, kind, status;
  final int severity;
  final double lat, lng;
  final String? message;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;

  const SosEvent({
    required this.id,
    required this.triggeredBy,
    required this.kind,
    required this.status,
    required this.severity,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.runId,
    this.tripId,
    this.parentId,
    this.driverId,
    this.message,
    this.meta,
  });

  factory SosEvent.fromJson(Map<String, dynamic> j) => SosEvent(
        id: j['id'] as String,
        runId: j['run_id'] as String?,
        tripId: j['trip_id'] as String?,
        triggeredBy: j['triggered_by'] as String,
        parentId: j['parent_id'] as String?,
        driverId: j['driver_id'] as String?,
        kind: j['kind'] as String,
        status: j['status'] as String,
        severity: (j['severity'] as num).toInt(),
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        message: j['message'] as String?,
        meta: (j['meta'] as Map?)?.cast<String, dynamic>(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
