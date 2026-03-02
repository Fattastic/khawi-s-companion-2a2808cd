import 'package:khawi_flutter/core/utils/json_readers.dart';

class JuniorLocation {
  final String id;
  final String runId;
  final String userId;
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime createdAt;

  JuniorLocation({
    required this.id,
    required this.runId,
    required this.userId,
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
    this.accuracy,
    required this.createdAt,
  });

  factory JuniorLocation.fromJson(Map<String, dynamic> json) {
    return JuniorLocation(
      id: readString(json, 'id'),
      runId: readString(json, 'run_id'),
      userId: readString(json, 'user_id'),
      lat: readDouble(json, 'lat'),
      lng: readDouble(json, 'lng'),
      heading: readDouble(json, 'heading'),
      speed: readDouble(json, 'speed'),
      accuracy: readDouble(json, 'accuracy'),
      createdAt: DateTime.parse(readString(json, 'created_at')),
    );
  }
}
