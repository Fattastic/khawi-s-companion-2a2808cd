// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrustStateDtoImpl _$$TrustStateDtoImplFromJson(Map<String, dynamic> json) =>
    _$TrustStateDtoImpl(
      userId: json['userId'] as String,
      tier: json['tier'] as String,
      score: (json['score'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      explain:
          json['explain'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TrustStateDtoImplToJson(_$TrustStateDtoImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tier': instance.tier,
      'score': instance.score,
      'confidence': instance.confidence,
      'explain': instance.explain,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$GetTrustStateResponseDtoImpl _$$GetTrustStateResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$GetTrustStateResponseDtoImpl(
      trust: TrustStateDto.fromJson(json['trust'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetTrustStateResponseDtoImplToJson(
        _$GetTrustStateResponseDtoImpl instance) =>
    <String, dynamic>{
      'trust': instance.trust,
    };

_$TrustEventDtoImpl _$$TrustEventDtoImplFromJson(Map<String, dynamic> json) =>
    _$TrustEventDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      actor: json['actor'] as String,
      eventType: json['eventType'] as String,
      fromTier: json['fromTier'] as String?,
      toTier: json['toTier'] as String?,
      payload:
          json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrustEventDtoImplToJson(_$TrustEventDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'actor': instance.actor,
      'eventType': instance.eventType,
      'fromTier': instance.fromTier,
      'toTier': instance.toTier,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
    };
