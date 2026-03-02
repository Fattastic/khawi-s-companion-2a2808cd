import 'package:freezed_annotation/freezed_annotation.dart';

part 'trust_dtos.freezed.dart';
part 'trust_dtos.g.dart';

@freezed
class TrustStateDto with _$TrustStateDto {
  const factory TrustStateDto({
    required String userId,
    required String tier, // bronze/silver/gold/platinum
    required double score,
    required double confidence,
    @Default(<String, dynamic>{}) Map<String, dynamic> explain,
    required DateTime updatedAt,
  }) = _TrustStateDto;

  factory TrustStateDto.fromJson(Map<String, dynamic> json) =>
      _$TrustStateDtoFromJson(json);
}

@freezed
class GetTrustStateResponseDto with _$GetTrustStateResponseDto {
  const factory GetTrustStateResponseDto({
    required TrustStateDto trust,
  }) = _GetTrustStateResponseDto;

  factory GetTrustStateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GetTrustStateResponseDtoFromJson(json);
}

@freezed
class TrustEventDto with _$TrustEventDto {
  const factory TrustEventDto({
    required String id,
    required String userId,
    required String actor,
    required String eventType,
    String? fromTier,
    String? toTier,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    required DateTime createdAt,
  }) = _TrustEventDto;

  factory TrustEventDto.fromJson(Map<String, dynamic> json) =>
      _$TrustEventDtoFromJson(json);
}
