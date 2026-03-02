import 'package:freezed_annotation/freezed_annotation.dart';

part 'redemption_dtos.freezed.dart';
part 'redemption_dtos.g.dart';

@freezed
class RedeemRewardRequestDto with _$RedeemRewardRequestDto {
  const factory RedeemRewardRequestDto({
    required String rewardId,
    @Default(<String, dynamic>{}) Map<String, dynamic> options,
  }) = _RedeemRewardRequestDto;

  factory RedeemRewardRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RedeemRewardRequestDtoFromJson(json);
}

@freezed
class RedemptionDto with _$RedemptionDto {
  const factory RedemptionDto({
    required String id,
    required String userId,
    required String rewardId,
    required int xpCostSnapshot,
    required String status, // requested/approved/delivered/rejected/canceled
    @Default(<String, dynamic>{}) Map<String, dynamic> fulfillmentPayload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RedemptionDto;

  factory RedemptionDto.fromJson(Map<String, dynamic> json) =>
      _$RedemptionDtoFromJson(json);
}

@freezed
class RedeemRewardResponseDto with _$RedeemRewardResponseDto {
  const factory RedeemRewardResponseDto({
    required RedemptionDto redemption,
    required int xpBalanceAfter,
  }) = _RedeemRewardResponseDto;

  factory RedeemRewardResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RedeemRewardResponseDtoFromJson(json);
}
