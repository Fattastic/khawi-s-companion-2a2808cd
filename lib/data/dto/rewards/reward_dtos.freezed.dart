// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reward_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RewardDto _$RewardDtoFromJson(Map<String, dynamic> json) {
  return _RewardDto.fromJson(json);
}

/// @nodoc
mixin _$RewardDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get titleKey => throw _privateConstructorUsedError;
  String get descriptionKey => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // 'symbolic' | 'functional' | 'partner'
  String get deliveryType =>
      throw _privateConstructorUsedError; // 'in_app' | 'coupon_code' | 'external_link' | 'manual_fulfillment'
  int get xpCost => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get requiresKhawiPlus => throw _privateConstructorUsedError;
  String get minTrustTier =>
      throw _privateConstructorUsedError; // 'bronze'|'silver'|'gold'|'platinum'
  int? get maxRedemptionsPerUser => throw _privateConstructorUsedError;
  int? get maxRedemptionsTotal => throw _privateConstructorUsedError;
  DateTime? get redemptionWindowStart => throw _privateConstructorUsedError;
  DateTime? get redemptionWindowEnd => throw _privateConstructorUsedError;
  Map<String, dynamic> get meta => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RewardDtoCopyWith<RewardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardDtoCopyWith<$Res> {
  factory $RewardDtoCopyWith(RewardDto value, $Res Function(RewardDto) then) =
      _$RewardDtoCopyWithImpl<$Res, RewardDto>;
  @useResult
  $Res call(
      {String id,
      String code,
      String titleKey,
      String descriptionKey,
      String category,
      String deliveryType,
      int xpCost,
      bool isActive,
      bool requiresKhawiPlus,
      String minTrustTier,
      int? maxRedemptionsPerUser,
      int? maxRedemptionsTotal,
      DateTime? redemptionWindowStart,
      DateTime? redemptionWindowEnd,
      Map<String, dynamic> meta});
}

/// @nodoc
class _$RewardDtoCopyWithImpl<$Res, $Val extends RewardDto>
    implements $RewardDtoCopyWith<$Res> {
  _$RewardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? category = null,
    Object? deliveryType = null,
    Object? xpCost = null,
    Object? isActive = null,
    Object? requiresKhawiPlus = null,
    Object? minTrustTier = null,
    Object? maxRedemptionsPerUser = freezed,
    Object? maxRedemptionsTotal = freezed,
    Object? redemptionWindowStart = freezed,
    Object? redemptionWindowEnd = freezed,
    Object? meta = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      titleKey: null == titleKey
          ? _value.titleKey
          : titleKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryType: null == deliveryType
          ? _value.deliveryType
          : deliveryType // ignore: cast_nullable_to_non_nullable
              as String,
      xpCost: null == xpCost
          ? _value.xpCost
          : xpCost // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresKhawiPlus: null == requiresKhawiPlus
          ? _value.requiresKhawiPlus
          : requiresKhawiPlus // ignore: cast_nullable_to_non_nullable
              as bool,
      minTrustTier: null == minTrustTier
          ? _value.minTrustTier
          : minTrustTier // ignore: cast_nullable_to_non_nullable
              as String,
      maxRedemptionsPerUser: freezed == maxRedemptionsPerUser
          ? _value.maxRedemptionsPerUser
          : maxRedemptionsPerUser // ignore: cast_nullable_to_non_nullable
              as int?,
      maxRedemptionsTotal: freezed == maxRedemptionsTotal
          ? _value.maxRedemptionsTotal
          : maxRedemptionsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      redemptionWindowStart: freezed == redemptionWindowStart
          ? _value.redemptionWindowStart
          : redemptionWindowStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redemptionWindowEnd: freezed == redemptionWindowEnd
          ? _value.redemptionWindowEnd
          : redemptionWindowEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RewardDtoImplCopyWith<$Res>
    implements $RewardDtoCopyWith<$Res> {
  factory _$$RewardDtoImplCopyWith(
          _$RewardDtoImpl value, $Res Function(_$RewardDtoImpl) then) =
      __$$RewardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String titleKey,
      String descriptionKey,
      String category,
      String deliveryType,
      int xpCost,
      bool isActive,
      bool requiresKhawiPlus,
      String minTrustTier,
      int? maxRedemptionsPerUser,
      int? maxRedemptionsTotal,
      DateTime? redemptionWindowStart,
      DateTime? redemptionWindowEnd,
      Map<String, dynamic> meta});
}

/// @nodoc
class __$$RewardDtoImplCopyWithImpl<$Res>
    extends _$RewardDtoCopyWithImpl<$Res, _$RewardDtoImpl>
    implements _$$RewardDtoImplCopyWith<$Res> {
  __$$RewardDtoImplCopyWithImpl(
      _$RewardDtoImpl _value, $Res Function(_$RewardDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? category = null,
    Object? deliveryType = null,
    Object? xpCost = null,
    Object? isActive = null,
    Object? requiresKhawiPlus = null,
    Object? minTrustTier = null,
    Object? maxRedemptionsPerUser = freezed,
    Object? maxRedemptionsTotal = freezed,
    Object? redemptionWindowStart = freezed,
    Object? redemptionWindowEnd = freezed,
    Object? meta = null,
  }) {
    return _then(_$RewardDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      titleKey: null == titleKey
          ? _value.titleKey
          : titleKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryType: null == deliveryType
          ? _value.deliveryType
          : deliveryType // ignore: cast_nullable_to_non_nullable
              as String,
      xpCost: null == xpCost
          ? _value.xpCost
          : xpCost // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresKhawiPlus: null == requiresKhawiPlus
          ? _value.requiresKhawiPlus
          : requiresKhawiPlus // ignore: cast_nullable_to_non_nullable
              as bool,
      minTrustTier: null == minTrustTier
          ? _value.minTrustTier
          : minTrustTier // ignore: cast_nullable_to_non_nullable
              as String,
      maxRedemptionsPerUser: freezed == maxRedemptionsPerUser
          ? _value.maxRedemptionsPerUser
          : maxRedemptionsPerUser // ignore: cast_nullable_to_non_nullable
              as int?,
      maxRedemptionsTotal: freezed == maxRedemptionsTotal
          ? _value.maxRedemptionsTotal
          : maxRedemptionsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      redemptionWindowStart: freezed == redemptionWindowStart
          ? _value.redemptionWindowStart
          : redemptionWindowStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redemptionWindowEnd: freezed == redemptionWindowEnd
          ? _value.redemptionWindowEnd
          : redemptionWindowEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      meta: null == meta
          ? _value._meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardDtoImpl implements _RewardDto {
  const _$RewardDtoImpl(
      {required this.id,
      required this.code,
      required this.titleKey,
      required this.descriptionKey,
      required this.category,
      required this.deliveryType,
      required this.xpCost,
      required this.isActive,
      required this.requiresKhawiPlus,
      required this.minTrustTier,
      this.maxRedemptionsPerUser,
      this.maxRedemptionsTotal,
      this.redemptionWindowStart,
      this.redemptionWindowEnd,
      final Map<String, dynamic> meta = const <String, dynamic>{}})
      : _meta = meta;

  factory _$RewardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String titleKey;
  @override
  final String descriptionKey;
  @override
  final String category;
// 'symbolic' | 'functional' | 'partner'
  @override
  final String deliveryType;
// 'in_app' | 'coupon_code' | 'external_link' | 'manual_fulfillment'
  @override
  final int xpCost;
  @override
  final bool isActive;
  @override
  final bool requiresKhawiPlus;
  @override
  final String minTrustTier;
// 'bronze'|'silver'|'gold'|'platinum'
  @override
  final int? maxRedemptionsPerUser;
  @override
  final int? maxRedemptionsTotal;
  @override
  final DateTime? redemptionWindowStart;
  @override
  final DateTime? redemptionWindowEnd;
  final Map<String, dynamic> _meta;
  @override
  @JsonKey()
  Map<String, dynamic> get meta {
    if (_meta is EqualUnmodifiableMapView) return _meta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_meta);
  }

  @override
  String toString() {
    return 'RewardDto(id: $id, code: $code, titleKey: $titleKey, descriptionKey: $descriptionKey, category: $category, deliveryType: $deliveryType, xpCost: $xpCost, isActive: $isActive, requiresKhawiPlus: $requiresKhawiPlus, minTrustTier: $minTrustTier, maxRedemptionsPerUser: $maxRedemptionsPerUser, maxRedemptionsTotal: $maxRedemptionsTotal, redemptionWindowStart: $redemptionWindowStart, redemptionWindowEnd: $redemptionWindowEnd, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.titleKey, titleKey) ||
                other.titleKey == titleKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.deliveryType, deliveryType) ||
                other.deliveryType == deliveryType) &&
            (identical(other.xpCost, xpCost) || other.xpCost == xpCost) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.requiresKhawiPlus, requiresKhawiPlus) ||
                other.requiresKhawiPlus == requiresKhawiPlus) &&
            (identical(other.minTrustTier, minTrustTier) ||
                other.minTrustTier == minTrustTier) &&
            (identical(other.maxRedemptionsPerUser, maxRedemptionsPerUser) ||
                other.maxRedemptionsPerUser == maxRedemptionsPerUser) &&
            (identical(other.maxRedemptionsTotal, maxRedemptionsTotal) ||
                other.maxRedemptionsTotal == maxRedemptionsTotal) &&
            (identical(other.redemptionWindowStart, redemptionWindowStart) ||
                other.redemptionWindowStart == redemptionWindowStart) &&
            (identical(other.redemptionWindowEnd, redemptionWindowEnd) ||
                other.redemptionWindowEnd == redemptionWindowEnd) &&
            const DeepCollectionEquality().equals(other._meta, _meta));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      titleKey,
      descriptionKey,
      category,
      deliveryType,
      xpCost,
      isActive,
      requiresKhawiPlus,
      minTrustTier,
      maxRedemptionsPerUser,
      maxRedemptionsTotal,
      redemptionWindowStart,
      redemptionWindowEnd,
      const DeepCollectionEquality().hash(_meta));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardDtoImplCopyWith<_$RewardDtoImpl> get copyWith =>
      __$$RewardDtoImplCopyWithImpl<_$RewardDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardDtoImplToJson(
      this,
    );
  }
}

abstract class _RewardDto implements RewardDto {
  const factory _RewardDto(
      {required final String id,
      required final String code,
      required final String titleKey,
      required final String descriptionKey,
      required final String category,
      required final String deliveryType,
      required final int xpCost,
      required final bool isActive,
      required final bool requiresKhawiPlus,
      required final String minTrustTier,
      final int? maxRedemptionsPerUser,
      final int? maxRedemptionsTotal,
      final DateTime? redemptionWindowStart,
      final DateTime? redemptionWindowEnd,
      final Map<String, dynamic> meta}) = _$RewardDtoImpl;

  factory _RewardDto.fromJson(Map<String, dynamic> json) =
      _$RewardDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get titleKey;
  @override
  String get descriptionKey;
  @override
  String get category;
  @override // 'symbolic' | 'functional' | 'partner'
  String get deliveryType;
  @override // 'in_app' | 'coupon_code' | 'external_link' | 'manual_fulfillment'
  int get xpCost;
  @override
  bool get isActive;
  @override
  bool get requiresKhawiPlus;
  @override
  String get minTrustTier;
  @override // 'bronze'|'silver'|'gold'|'platinum'
  int? get maxRedemptionsPerUser;
  @override
  int? get maxRedemptionsTotal;
  @override
  DateTime? get redemptionWindowStart;
  @override
  DateTime? get redemptionWindowEnd;
  @override
  Map<String, dynamic> get meta;
  @override
  @JsonKey(ignore: true)
  _$$RewardDtoImplCopyWith<_$RewardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListRewardsResponseDto _$ListRewardsResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _ListRewardsResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ListRewardsResponseDto {
  List<RewardDto> get rewards => throw _privateConstructorUsedError;
  bool get fromCache => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ListRewardsResponseDtoCopyWith<ListRewardsResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListRewardsResponseDtoCopyWith<$Res> {
  factory $ListRewardsResponseDtoCopyWith(ListRewardsResponseDto value,
          $Res Function(ListRewardsResponseDto) then) =
      _$ListRewardsResponseDtoCopyWithImpl<$Res, ListRewardsResponseDto>;
  @useResult
  $Res call({List<RewardDto> rewards, bool fromCache});
}

/// @nodoc
class _$ListRewardsResponseDtoCopyWithImpl<$Res,
        $Val extends ListRewardsResponseDto>
    implements $ListRewardsResponseDtoCopyWith<$Res> {
  _$ListRewardsResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewards = null,
    Object? fromCache = null,
  }) {
    return _then(_value.copyWith(
      rewards: null == rewards
          ? _value.rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<RewardDto>,
      fromCache: null == fromCache
          ? _value.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListRewardsResponseDtoImplCopyWith<$Res>
    implements $ListRewardsResponseDtoCopyWith<$Res> {
  factory _$$ListRewardsResponseDtoImplCopyWith(
          _$ListRewardsResponseDtoImpl value,
          $Res Function(_$ListRewardsResponseDtoImpl) then) =
      __$$ListRewardsResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<RewardDto> rewards, bool fromCache});
}

/// @nodoc
class __$$ListRewardsResponseDtoImplCopyWithImpl<$Res>
    extends _$ListRewardsResponseDtoCopyWithImpl<$Res,
        _$ListRewardsResponseDtoImpl>
    implements _$$ListRewardsResponseDtoImplCopyWith<$Res> {
  __$$ListRewardsResponseDtoImplCopyWithImpl(
      _$ListRewardsResponseDtoImpl _value,
      $Res Function(_$ListRewardsResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewards = null,
    Object? fromCache = null,
  }) {
    return _then(_$ListRewardsResponseDtoImpl(
      rewards: null == rewards
          ? _value._rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<RewardDto>,
      fromCache: null == fromCache
          ? _value.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListRewardsResponseDtoImpl implements _ListRewardsResponseDto {
  const _$ListRewardsResponseDtoImpl(
      {required final List<RewardDto> rewards, this.fromCache = false})
      : _rewards = rewards;

  factory _$ListRewardsResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListRewardsResponseDtoImplFromJson(json);

  final List<RewardDto> _rewards;
  @override
  List<RewardDto> get rewards {
    if (_rewards is EqualUnmodifiableListView) return _rewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewards);
  }

  @override
  @JsonKey()
  final bool fromCache;

  @override
  String toString() {
    return 'ListRewardsResponseDto(rewards: $rewards, fromCache: $fromCache)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListRewardsResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._rewards, _rewards) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_rewards), fromCache);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ListRewardsResponseDtoImplCopyWith<_$ListRewardsResponseDtoImpl>
      get copyWith => __$$ListRewardsResponseDtoImplCopyWithImpl<
          _$ListRewardsResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListRewardsResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _ListRewardsResponseDto implements ListRewardsResponseDto {
  const factory _ListRewardsResponseDto(
      {required final List<RewardDto> rewards,
      final bool fromCache}) = _$ListRewardsResponseDtoImpl;

  factory _ListRewardsResponseDto.fromJson(Map<String, dynamic> json) =
      _$ListRewardsResponseDtoImpl.fromJson;

  @override
  List<RewardDto> get rewards;
  @override
  bool get fromCache;
  @override
  @JsonKey(ignore: true)
  _$$ListRewardsResponseDtoImplCopyWith<_$ListRewardsResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
