import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;

Map<String, dynamic> buildSendJoinRequestParams({
  required String tripId,
  double? pickupLat,
  double? pickupLng,
  String? pickupLabel,
  double? flexOfferSar,
  String? flexNote,
}) {
  final normalizedTripId = tripId.trim();
  if (normalizedTripId.isEmpty) {
    throw ArgumentError.value(tripId, 'tripId', 'Trip ID must not be empty');
  }

  double? sanitizeCoordinate(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }

  final normalizedLabel = pickupLabel?.trim();
  final normalizedFlexNote = flexNote?.trim();
  final sanitizedOffer = (flexOfferSar == null ||
          flexOfferSar.isNaN ||
          flexOfferSar.isInfinite ||
          flexOfferSar <= 0)
      ? null
      : flexOfferSar;

  return {
    'p_trip_id': normalizedTripId,
    'p_pickup_lat': sanitizeCoordinate(pickupLat),
    'p_pickup_lng': sanitizeCoordinate(pickupLng),
    'p_pickup_label': (normalizedLabel == null || normalizedLabel.isEmpty)
        ? null
        : normalizedLabel,
    'p_flex_offer_sar': sanitizedOffer,
    'p_flex_note': (normalizedFlexNote == null || normalizedFlexNote.isEmpty)
        ? null
        : normalizedFlexNote,
  };
}

class RequestsRepo {
  RequestsRepo(this.sb);
  final SupabaseClient sb;

  Stream<List<TripRequest>> watchSent(String passengerId) {
    if (kUseDevMode) {
      return Stream.value([]);
    }
    return sb
        .from(DbTable.tripRequests)
        .stream(primaryKey: ['id'])
        .eq('passenger_id', passengerId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map((r) => TripRequest.fromJson(r)).toList());
  }

  Stream<List<TripRequest>> watchIncomingForDriver(String driverId) {
    if (kUseDevMode) {
      // Return mock incoming requests for demo
      return Stream.value([
        TripRequest(
          id: 'req_1',
          tripId: 'trip_1',
          passengerId: 'passenger_1',
          status: RequestStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        TripRequest(
          id: 'req_2',
          tripId: 'trip_1',
          passengerId: 'passenger_2',
          status: RequestStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ]);
    }
    return sb
        .from(DbTable.tripRequests)
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId) // requires denormalized driver_id
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map((r) => TripRequest.fromJson(r)).toList());
  }

  Future<TripRequest> sendJoinRequest(
    String tripId, {
    double? pickupLat,
    double? pickupLng,
    String? pickupLabel,
    double? flexOfferSar,
    String? flexNote,
  }) async {
    final params = buildSendJoinRequestParams(
      tripId: tripId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupLabel: pickupLabel,
      flexOfferSar: flexOfferSar,
      flexNote: flexNote,
    );

    // DEV MODE: Return mock request
    if (kUseDevMode) {
      return TripRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        tripId: params['p_trip_id'] as String,
        passengerId: 'dev_user_id',
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
        flexOfferSar: params['p_flex_offer_sar'] as double?,
        flexNote: params['p_flex_note'] as String?,
      );
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.sendJoinRequest,
      params: params,
    );
    return TripRequest.fromJson(res);
  }

  Future<void> cancelJoinRequest(String requestId) async {
    // DEV MODE: No-op
    if (kUseDevMode) return;
    await sb.rpc<void>(
      DbRpc.cancelJoinRequest,
      params: {'p_request_id': requestId},
    );
  }

  Future<TripRequest> driverAccept(String requestId) async {
    // DEV MODE: Return mock accepted request
    if (kUseDevMode) {
      return TripRequest(
        id: requestId,
        tripId: 'trip_1',
        passengerId: 'passenger_1',
        status: RequestStatus.accepted,
        createdAt: DateTime.now(),
      );
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.driverAcceptRequest,
      params: {'p_request_id': requestId},
    );
    return TripRequest.fromJson(res);
  }

  Future<TripRequest> driverDecline(String requestId) async {
    // DEV MODE: Return mock declined request
    if (kUseDevMode) {
      return TripRequest(
        id: requestId,
        tripId: 'trip_1',
        passengerId: 'passenger_1',
        status: RequestStatus.declined,
        createdAt: DateTime.now(),
      );
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.driverDeclineRequest,
      params: {'p_request_id': requestId},
    );
    return TripRequest.fromJson(res);
  }

  /// Update request status with transition validation.
  ///
  /// This validates the transition client-side before calling the server.
  /// The server also enforces transitions via the `update_request_status` RPC.
  ///
  /// Throws [InvalidStatusTransitionException] if the transition is not allowed.
  Future<TripRequest> updateStatus({
    required String requestId,
    required RequestStatus currentStatus,
    required RequestStatus newStatus,
  }) async {
    // Client-side validation (fast fail)
    validateTransition(currentStatus, newStatus);

    // DEV MODE: Return mock updated request
    if (kUseDevMode) {
      return TripRequest(
        id: requestId,
        tripId: 'trip_1',
        passengerId: 'passenger_1',
        status: newStatus,
        createdAt: DateTime.now(),
      );
    }

    // Server-side call with transition enforcement
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.updateRequestStatus,
      params: {
        'p_request_id': requestId,
        'p_new_status': requestStatusToString(newStatus),
      },
    );
    return TripRequest.fromJson(res);
  }

  /// Mark passenger as picked up (driver action).
  /// Validates: accepted → picked_up
  Future<TripRequest> markPickedUp(
    String requestId,
    RequestStatus currentStatus,
  ) {
    return updateStatus(
      requestId: requestId,
      currentStatus: currentStatus,
      newStatus: RequestStatus.pickedUp,
    );
  }

  /// Mark passenger as dropped off (driver action).
  /// Validates: picked_up → dropped_off
  Future<TripRequest> markDroppedOff(
    String requestId,
    RequestStatus currentStatus,
  ) {
    return updateStatus(
      requestId: requestId,
      currentStatus: currentStatus,
      newStatus: RequestStatus.droppedOff,
    );
  }

  /// Complete the ride (system/driver action).
  /// Validates: dropped_off → completed
  Future<TripRequest> completeRide(
    String requestId,
    RequestStatus currentStatus,
  ) {
    return updateStatus(
      requestId: requestId,
      currentStatus: currentStatus,
      newStatus: RequestStatus.completed,
    );
  }

  // Backward compatibility alias methods (if needed by existing controller)
  Stream<List<TripRequest>> watchSentRequests(String uid) => watchSent(uid);
  Stream<List<TripRequest>> watchIncomingRequestsForDriver(String uid) =>
      watchIncomingForDriver(uid);
  Future<void> acceptRequest(String reqId) => driverAccept(reqId);
  Future<void> declineRequest(String reqId) => driverDecline(reqId);
  Future<void> cancelRequest(String reqId) => cancelJoinRequest(reqId);
}
