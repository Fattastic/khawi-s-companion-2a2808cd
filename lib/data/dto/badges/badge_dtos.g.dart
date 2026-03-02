// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeDtoImpl _$$BadgeDtoImplFromJson(Map<String, dynamic> json) =>
    _$BadgeDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      titleKey: json['titleKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      visibility: json['visibility'] as String,
      isActive: json['isActive'] as bool,
      criteria: json['criteria'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      iconAsset: json['iconAsset'] as String?,
    );

Map<String, dynamic> _$$BadgeDtoImplToJson(_$BadgeDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'titleKey': instance.titleKey,
      'descriptionKey': instance.descriptionKey,
      'visibility': instance.visibility,
      'isActive': instance.isActive,
      'criteria': instance.criteria,
      'iconAsset': instance.iconAsset,
    };

_$UserBadgeDtoImpl _$$UserBadgeDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserBadgeDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      badgeId: json['badgeId'] as String,
      status: json['status'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      evidence: json['evidence'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$$UserBadgeDtoImplToJson(_$UserBadgeDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'badgeId': instance.badgeId,
      'status': instance.status,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'evidence': instance.evidence,
    };

_$ListUserBadgesResponseDtoImpl _$$ListUserBadgesResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ListUserBadgesResponseDtoImpl(
      badgesCatalog: (json['badgesCatalog'] as List<dynamic>)
          .map((e) => BadgeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      userBadges: (json['userBadges'] as List<dynamic>)
          .map((e) => UserBadgeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ListUserBadgesResponseDtoImplToJson(
        _$ListUserBadgesResponseDtoImpl instance) =>
    <String, dynamic>{
      'badgesCatalog': instance.badgesCatalog,
      'userBadges': instance.userBadges,
    };
