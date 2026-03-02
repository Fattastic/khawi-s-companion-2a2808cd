/// Request status lifecycle:
/// ```
/// pending → accepted → picked_up → dropped_off → completed
///    ↓          ↓
/// declined  cancelled
///    ↓
/// expired (auto by system when trip fills)
/// ```
enum RequestStatus {
  pending,
  accepted,
  declined,
  cancelled,
  expired,
  pickedUp,
  droppedOff,
  completed,
}

/// Allowed transitions for each status.
/// This is the single source of truth for booking lifecycle.
const Map<RequestStatus, Set<RequestStatus>> allowedRequestTransitions = {
  RequestStatus.pending: {
    RequestStatus.accepted,
    RequestStatus.declined,
    RequestStatus.cancelled,
    RequestStatus.expired,
  },
  RequestStatus.accepted: {
    RequestStatus.pickedUp,
    RequestStatus.cancelled,
  },
  RequestStatus.pickedUp: {
    RequestStatus.droppedOff,
  },
  RequestStatus.droppedOff: {
    RequestStatus.completed,
  },
  // Terminal states - no further transitions allowed
  RequestStatus.declined: {},
  RequestStatus.cancelled: {},
  RequestStatus.expired: {},
  RequestStatus.completed: {},
};

/// Exception thrown when an invalid status transition is attempted.
class InvalidStatusTransitionException implements Exception {
  final RequestStatus from;
  final RequestStatus to;

  const InvalidStatusTransitionException(this.from, this.to);

  @override
  String toString() => 'Invalid transition: $from → $to';
}

/// Check if a status transition is allowed.
bool isTransitionAllowed(RequestStatus from, RequestStatus to) {
  return allowedRequestTransitions[from]?.contains(to) ?? false;
}

/// Validate a transition and throw if invalid.
void validateTransition(RequestStatus from, RequestStatus to) {
  if (!isTransitionAllowed(from, to)) {
    throw InvalidStatusTransitionException(from, to);
  }
}

RequestStatus requestStatusFromString(String v) => switch (v) {
      'accepted' => RequestStatus.accepted,
      'declined' => RequestStatus.declined,
      'cancelled' => RequestStatus.cancelled,
      'expired' => RequestStatus.expired,
      'picked_up' => RequestStatus.pickedUp,
      'dropped_off' => RequestStatus.droppedOff,
      'completed' => RequestStatus.completed,
      _ => RequestStatus.pending,
    };

String requestStatusToString(RequestStatus s) => switch (s) {
      RequestStatus.pending => 'pending',
      RequestStatus.accepted => 'accepted',
      RequestStatus.declined => 'declined',
      RequestStatus.cancelled => 'cancelled',
      RequestStatus.expired => 'expired',
      RequestStatus.pickedUp => 'picked_up',
      RequestStatus.droppedOff => 'dropped_off',
      RequestStatus.completed => 'completed',
    };

class TripRequest {
  final String id, tripId, passengerId;
  final String? driverId;
  final RequestStatus status;
  final DateTime createdAt;
  final double? flexOfferSar;
  final String? flexNote;

  /// Rating given by this user for this trip (1-5).
  final int? ratingGiven;

  /// Rating received from the counterpart (1-5).
  final int? ratingReceived;

  const TripRequest({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.status,
    required this.createdAt,
    this.driverId,
    this.flexOfferSar,
    this.flexNote,
    this.ratingGiven,
    this.ratingReceived,
  });

  factory TripRequest.fromJson(Map<String, dynamic> j) => TripRequest(
        id: j['id'] as String,
        tripId: j['trip_id'] as String,
        passengerId: j['passenger_id'] as String,
        driverId: j['driver_id'] as String?,
        status: requestStatusFromString((j['status'] as String?) ?? 'pending'),
        createdAt: DateTime.parse(j['created_at'] as String),
        flexOfferSar: (j['flex_offer_sar'] as num?)?.toDouble(),
        flexNote: (j['flex_note'] as String?)?.trim(),
        ratingGiven: j['rating_given'] as int?,
        ratingReceived: j['rating_received'] as int?,
      );

  bool get hasFlexOffer => flexOfferSar != null && flexOfferSar! > 0;
}
