// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardDtoImpl _$$RewardDtoImplFromJson(Map<String, dynamic> json) =>
    _$RewardDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      titleKey: json['titleKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      category: json['category'] as String,
      deliveryType: json['deliveryType'] as String,
      xpCost: (json['xpCost'] as num).toInt(),
      isActive: json['isActive'] as bool,
      requiresKhawiPlus: json['requiresKhawiPlus'] as bool,
      minTrustTier: json['minTrustTier'] as String,
      maxRedemptionsPerUser: (json['maxRedemptionsPerUser'] as num?)?.toInt(),
      maxRedemptionsTotal: (json['maxRedemptionsTotal'] as num?)?.toInt(),
      redemptionWindowStart: json['redemptionWindowStart'] == null
          ? null
          : DateTime.parse(json['redemptionWindowStart'] as String),
      redemptionWindowEnd: json['redemptionWindowEnd'] == null
          ? null
          : DateTime.parse(json['redemptionWindowEnd'] as String),
      meta: json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

Map<String, dynamic> _$$RewardDtoImplToJson(_$RewardDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'titleKey': instance.titleKey,
      'descriptionKey': instance.descriptionKey,
      'category': instance.category,
      'deliveryType': instance.deliveryType,
      'xpCost': instance.xpCost,
      'isActive': instance.isActive,
      'requiresKhawiPlus': instance.requiresKhawiPlus,
      'minTrustTier': instance.minTrustTier,
      'maxRedemptionsPerUser': instance.maxRedemptionsPerUser,
      'maxRedemptionsTotal': instance.maxRedemptionsTotal,
      'redemptionWindowStart':
          instance.redemptionWindowStart?.toIso8601String(),
      'redemptionWindowEnd': instance.redemptionWindowEnd?.toIso8601String(),
      'meta': instance.meta,
    };

_$ListRewardsResponseDtoImpl _$$ListRewardsResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ListRewardsResponseDtoImpl(
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) => RewardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      fromCache: json['fromCache'] as bool? ?? false,
    );

Map<String, dynamic> _$$ListRewardsResponseDtoImplToJson(
        _$ListRewardsResponseDtoImpl instance) =>
    <String, dynamic>{
      'rewards': instance.rewards,
      'fromCache': instance.fromCache,
    };
