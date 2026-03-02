import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class TripMessage {
  final String id;
  @JsonKey(name: 'trip_id')
  final String tripId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  final String body;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? senderName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? senderAvatarUrl;

  @JsonKey(name: 'moderation_status')
  final String? moderationStatus;

  TripMessage({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
    this.moderationStatus,
  });

  factory TripMessage.fromJson(Map<String, dynamic> json) =>
      _$TripMessageFromJson(json);
  Map<String, dynamic> toJson() => _$TripMessageToJson(this);
}
