import 'package:khawi_flutter/core/utils/json_readers.dart';

class TripMessage {
  final String id;
  final String tripId;
  final String senderId;
  final String body;
  final DateTime createdAt;

  TripMessage({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory TripMessage.fromJson(Map<String, dynamic> json) {
    return TripMessage(
      id: readString(json, 'id'),
      tripId: readString(json, 'trip_id'),
      senderId: readString(json, 'sender_id'),
      body: readString(json, 'body'),
      createdAt: DateTime.parse(readString(json, 'created_at')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'sender_id': senderId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
