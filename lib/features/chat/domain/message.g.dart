// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripMessage _$TripMessageFromJson(Map<String, dynamic> json) => TripMessage(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      senderId: json['sender_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      moderationStatus: json['moderation_status'] as String?,
    );

Map<String, dynamic> _$TripMessageToJson(TripMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'sender_id': instance.senderId,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'moderation_status': instance.moderationStatus,
    };
