// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedeemRewardRequestDtoImpl _$$RedeemRewardRequestDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemRewardRequestDtoImpl(
      rewardId: json['rewardId'] as String,
      options:
          json['options'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

Map<String, dynamic> _$$RedeemRewardRequestDtoImplToJson(
        _$RedeemRewardRequestDtoImpl instance) =>
    <String, dynamic>{
      'rewardId': instance.rewardId,
      'options': instance.options,
    };

_$RedemptionDtoImpl _$$RedemptionDtoImplFromJson(Map<String, dynamic> json) =>
    _$RedemptionDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rewardId: json['rewardId'] as String,
      xpCostSnapshot: (json['xpCostSnapshot'] as num).toInt(),
      status: json['status'] as String,
      fulfillmentPayload: json['fulfillmentPayload'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RedemptionDtoImplToJson(_$RedemptionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'rewardId': instance.rewardId,
      'xpCostSnapshot': instance.xpCostSnapshot,
      'status': instance.status,
      'fulfillmentPayload': instance.fulfillmentPayload,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$RedeemRewardResponseDtoImpl _$$RedeemRewardResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RedeemRewardResponseDtoImpl(
      redemption:
          RedemptionDto.fromJson(json['redemption'] as Map<String, dynamic>),
      xpBalanceAfter: (json['xpBalanceAfter'] as num).toInt(),
    );

Map<String, dynamic> _$$RedeemRewardResponseDtoImplToJson(
        _$RedeemRewardResponseDtoImpl instance) =>
    <String, dynamic>{
      'redemption': instance.redemption,
      'xpBalanceAfter': instance.xpBalanceAfter,
    };
