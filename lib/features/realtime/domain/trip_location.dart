import 'package:khawi_flutter/core/utils/json_readers.dart';

class TripLocation {
  final String id;
  final String tripId;
  final String userId;
  final double lat;
  final double lng;
  final double heading;
  final double speed;
  final DateTime createdAt;

  TripLocation({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
    required this.createdAt,
  });

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      id: readString(json, 'id'),
      tripId: readString(json, 'trip_id'),
      userId: readString(json, 'user_id'),
      lat: readDouble(json, 'lat'),
      lng: readDouble(json, 'lng'),
      heading: readDouble(json, 'heading'),
      speed: readDouble(json, 'speed'),
      createdAt: DateTime.parse(readString(json, 'created_at')),
    );
  }
}
