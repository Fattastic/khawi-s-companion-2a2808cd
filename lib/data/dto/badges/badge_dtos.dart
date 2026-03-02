import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_dtos.freezed.dart';
part 'badge_dtos.g.dart';

@freezed
class BadgeDto with _$BadgeDto {
  const factory BadgeDto({
    required String id,
    required String code,
    required String titleKey,
    required String descriptionKey,
    required String visibility, // public/private/kids_only
    required bool isActive,
    @Default(<String, dynamic>{}) Map<String, dynamic> criteria,
    String? iconAsset,
  }) = _BadgeDto;

  factory BadgeDto.fromJson(Map<String, dynamic> json) =>
      _$BadgeDtoFromJson(json);
}

@freezed
class UserBadgeDto with _$UserBadgeDto {
  const factory UserBadgeDto({
    required String id,
    required String userId,
    required String badgeId,
    required String status, // earned/revoked
    required DateTime earnedAt,
    DateTime? revokedAt,
    @Default(<String, dynamic>{}) Map<String, dynamic> evidence,
  }) = _UserBadgeDto;

  factory UserBadgeDto.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeDtoFromJson(json);
}

@freezed
class ListUserBadgesResponseDto with _$ListUserBadgesResponseDto {
  const factory ListUserBadgesResponseDto({
    required List<BadgeDto> badgesCatalog,
    required List<UserBadgeDto> userBadges,
  }) = _ListUserBadgesResponseDto;

  factory ListUserBadgesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ListUserBadgesResponseDtoFromJson(json);
}
