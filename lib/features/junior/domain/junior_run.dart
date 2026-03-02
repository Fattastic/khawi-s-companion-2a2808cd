import 'package:khawi_flutter/core/utils/json_readers.dart';

class JuniorRun {
  final String id;
  final String kidId;
  final String parentId;
  final String? assignedDriverId;
  final String
      status; // planned, driver_assigned, picked_up, arrived, completed, cancelled
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final DateTime pickupTime;
  final String? tripId;

  JuniorRun({
    required this.id,
    required this.kidId,
    required this.parentId,
    this.assignedDriverId,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.pickupTime,
    this.tripId,
  });

  factory JuniorRun.fromJson(Map<String, dynamic> json) {
    return JuniorRun(
      id: readString(json, 'id'),
      kidId: readString(json, 'kid_id'),
      parentId: readString(json, 'parent_id'),
      assignedDriverId: readNullableString(json, 'assigned_driver_id'),
      status: readString(json, 'status'),
      pickupLat: readDouble(json, 'pickup_lat'),
      pickupLng: readDouble(json, 'pickup_lng'),
      dropoffLat: readDouble(json, 'dropoff_lat'),
      dropoffLng: readDouble(json, 'dropoff_lng'),
      pickupTime: DateTime.parse(readString(json, 'pickup_time')),
      tripId: readNullableString(json, 'trip_id'),
    );
  }
}
