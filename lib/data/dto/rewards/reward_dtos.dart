import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward_dtos.freezed.dart';
part 'reward_dtos.g.dart';

@freezed
class RewardDto with _$RewardDto {
  const factory RewardDto({
    required String id,
    required String code,
    required String titleKey,
    required String descriptionKey,
    required String category, // 'symbolic' | 'functional' | 'partner'
    required String
        deliveryType, // 'in_app' | 'coupon_code' | 'external_link' | 'manual_fulfillment'
    required int xpCost,
    required bool isActive,
    required bool requiresKhawiPlus,
    required String minTrustTier, // 'bronze'|'silver'|'gold'|'platinum'
    int? maxRedemptionsPerUser,
    int? maxRedemptionsTotal,
    DateTime? redemptionWindowStart,
    DateTime? redemptionWindowEnd,
    @Default(<String, dynamic>{}) Map<String, dynamic> meta,
  }) = _RewardDto;

  factory RewardDto.fromJson(Map<String, dynamic> json) =>
      _$RewardDtoFromJson(json);
}

@freezed
class ListRewardsResponseDto with _$ListRewardsResponseDto {
  const factory ListRewardsResponseDto({
    required List<RewardDto> rewards,
    @Default(false) bool fromCache,
  }) = _ListRewardsResponseDto;

  factory ListRewardsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ListRewardsResponseDtoFromJson(json);
}
