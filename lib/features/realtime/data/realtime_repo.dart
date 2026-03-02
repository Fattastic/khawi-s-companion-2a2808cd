import 'package:khawi_flutter/features/realtime/domain/trip_message.dart';
import 'package:khawi_flutter/features/realtime/domain/trip_location.dart';

abstract class RealtimeRepo {
  /// Stream of chat messages for a trip (ordered by time ASC)
  Stream<List<TripMessage>> watchTripMessages(String tripId);

  /// Send a message
  Future<void> sendMessage({required String tripId, required String body});

  /// Stream of participant locations (ordered by time DESC)
  /// Typically you only care about the latest one, but this gives history/updates.
  Stream<List<TripLocation>> watchTripLocations(String tripId);

  /// Post current location (Driver only in MVP)
  Future<void> updateLocation({
    required String tripId,
    required double lat,
    required double lng,
    double heading = 0,
    double speed = 0,
  });
}
