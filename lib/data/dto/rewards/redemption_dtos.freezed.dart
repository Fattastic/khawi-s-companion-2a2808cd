// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redemption_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RedeemRewardRequestDto _$RedeemRewardRequestDtoFromJson(
    Map<String, dynamic> json) {
  return _RedeemRewardRequestDto.fromJson(json);
}

/// @nodoc
mixin _$RedeemRewardRequestDto {
  String get rewardId => throw _privateConstructorUsedError;
  Map<String, dynamic> get options => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RedeemRewardRequestDtoCopyWith<RedeemRewardRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemRewardRequestDtoCopyWith<$Res> {
  factory $RedeemRewardRequestDtoCopyWith(RedeemRewardRequestDto value,
          $Res Function(RedeemRewardRequestDto) then) =
      _$RedeemRewardRequestDtoCopyWithImpl<$Res, RedeemRewardRequestDto>;
  @useResult
  $Res call({String rewardId, Map<String, dynamic> options});
}

/// @nodoc
class _$RedeemRewardRequestDtoCopyWithImpl<$Res,
        $Val extends RedeemRewardRequestDto>
    implements $RedeemRewardRequestDtoCopyWith<$Res> {
  _$RedeemRewardRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedeemRewardRequestDtoImplCopyWith<$Res>
    implements $RedeemRewardRequestDtoCopyWith<$Res> {
  factory _$$RedeemRewardRequestDtoImplCopyWith(
          _$RedeemRewardRequestDtoImpl value,
          $Res Function(_$RedeemRewardRequestDtoImpl) then) =
      __$$RedeemRewardRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rewardId, Map<String, dynamic> options});
}

/// @nodoc
class __$$RedeemRewardRequestDtoImplCopyWithImpl<$Res>
    extends _$RedeemRewardRequestDtoCopyWithImpl<$Res,
        _$RedeemRewardRequestDtoImpl>
    implements _$$RedeemRewardRequestDtoImplCopyWith<$Res> {
  __$$RedeemRewardRequestDtoImplCopyWithImpl(
      _$RedeemRewardRequestDtoImpl _value,
      $Res Function(_$RedeemRewardRequestDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
    Object? options = null,
  }) {
    return _then(_$RedeemRewardRequestDtoImpl(
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemRewardRequestDtoImpl implements _RedeemRewardRequestDto {
  const _$RedeemRewardRequestDtoImpl(
      {required this.rewardId,
      final Map<String, dynamic> options = const <String, dynamic>{}})
      : _options = options;

  factory _$RedeemRewardRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemRewardRequestDtoImplFromJson(json);

  @override
  final String rewardId;
  final Map<String, dynamic> _options;
  @override
  @JsonKey()
  Map<String, dynamic> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  String toString() {
    return 'RedeemRewardRequestDto(rewardId: $rewardId, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemRewardRequestDtoImpl &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, rewardId, const DeepCollectionEquality().hash(_options));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemRewardRequestDtoImplCopyWith<_$RedeemRewardRequestDtoImpl>
      get copyWith => __$$RedeemRewardRequestDtoImplCopyWithImpl<
          _$RedeemRewardRequestDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemRewardRequestDtoImplToJson(
      this,
    );
  }
}

abstract class _RedeemRewardRequestDto implements RedeemRewardRequestDto {
  const factory _RedeemRewardRequestDto(
      {required final String rewardId,
      final Map<String, dynamic> options}) = _$RedeemRewardRequestDtoImpl;

  factory _RedeemRewardRequestDto.fromJson(Map<String, dynamic> json) =
      _$RedeemRewardRequestDtoImpl.fromJson;

  @override
  String get rewardId;
  @override
  Map<String, dynamic> get options;
  @override
  @JsonKey(ignore: true)
  _$$RedeemRewardRequestDtoImplCopyWith<_$RedeemRewardRequestDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RedemptionDto _$RedemptionDtoFromJson(Map<String, dynamic> json) {
  return _RedemptionDto.fromJson(json);
}

/// @nodoc
mixin _$RedemptionDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get rewardId => throw _privateConstructorUsedError;
  int get xpCostSnapshot => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // requested/approved/delivered/rejected/canceled
  Map<String, dynamic> get fulfillmentPayload =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RedemptionDtoCopyWith<RedemptionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedemptionDtoCopyWith<$Res> {
  factory $RedemptionDtoCopyWith(
          RedemptionDto value, $Res Function(RedemptionDto) then) =
      _$RedemptionDtoCopyWithImpl<$Res, RedemptionDto>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String rewardId,
      int xpCostSnapshot,
      String status,
      Map<String, dynamic> fulfillmentPayload,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$RedemptionDtoCopyWithImpl<$Res, $Val extends RedemptionDto>
    implements $RedemptionDtoCopyWith<$Res> {
  _$RedemptionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? rewardId = null,
    Object? xpCostSnapshot = null,
    Object? status = null,
    Object? fulfillmentPayload = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      xpCostSnapshot: null == xpCostSnapshot
          ? _value.xpCostSnapshot
          : xpCostSnapshot // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      fulfillmentPayload: null == fulfillmentPayload
          ? _value.fulfillmentPayload
          : fulfillmentPayload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedemptionDtoImplCopyWith<$Res>
    implements $RedemptionDtoCopyWith<$Res> {
  factory _$$RedemptionDtoImplCopyWith(
          _$RedemptionDtoImpl value, $Res Function(_$RedemptionDtoImpl) then) =
      __$$RedemptionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String rewardId,
      int xpCostSnapshot,
      String status,
      Map<String, dynamic> fulfillmentPayload,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$RedemptionDtoImplCopyWithImpl<$Res>
    extends _$RedemptionDtoCopyWithImpl<$Res, _$RedemptionDtoImpl>
    implements _$$RedemptionDtoImplCopyWith<$Res> {
  __$$RedemptionDtoImplCopyWithImpl(
      _$RedemptionDtoImpl _value, $Res Function(_$RedemptionDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? rewardId = null,
    Object? xpCostSnapshot = null,
    Object? status = null,
    Object? fulfillmentPayload = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RedemptionDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      xpCostSnapshot: null == xpCostSnapshot
          ? _value.xpCostSnapshot
          : xpCostSnapshot // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      fulfillmentPayload: null == fulfillmentPayload
          ? _value._fulfillmentPayload
          : fulfillmentPayload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedemptionDtoImpl implements _RedemptionDto {
  const _$RedemptionDtoImpl(
      {required this.id,
      required this.userId,
      required this.rewardId,
      required this.xpCostSnapshot,
      required this.status,
      final Map<String, dynamic> fulfillmentPayload = const <String, dynamic>{},
      required this.createdAt,
      required this.updatedAt})
      : _fulfillmentPayload = fulfillmentPayload;

  factory _$RedemptionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedemptionDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String rewardId;
  @override
  final int xpCostSnapshot;
  @override
  final String status;
// requested/approved/delivered/rejected/canceled
  final Map<String, dynamic> _fulfillmentPayload;
// requested/approved/delivered/rejected/canceled
  @override
  @JsonKey()
  Map<String, dynamic> get fulfillmentPayload {
    if (_fulfillmentPayload is EqualUnmodifiableMapView)
      return _fulfillmentPayload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fulfillmentPayload);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RedemptionDto(id: $id, userId: $userId, rewardId: $rewardId, xpCostSnapshot: $xpCostSnapshot, status: $status, fulfillmentPayload: $fulfillmentPayload, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedemptionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId) &&
            (identical(other.xpCostSnapshot, xpCostSnapshot) ||
                other.xpCostSnapshot == xpCostSnapshot) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._fulfillmentPayload, _fulfillmentPayload) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      rewardId,
      xpCostSnapshot,
      status,
      const DeepCollectionEquality().hash(_fulfillmentPayload),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RedemptionDtoImplCopyWith<_$RedemptionDtoImpl> get copyWith =>
      __$$RedemptionDtoImplCopyWithImpl<_$RedemptionDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedemptionDtoImplToJson(
      this,
    );
  }
}

abstract class _RedemptionDto implements RedemptionDto {
  const factory _RedemptionDto(
      {required final String id,
      required final String userId,
      required final String rewardId,
      required final int xpCostSnapshot,
      required final String status,
      final Map<String, dynamic> fulfillmentPayload,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$RedemptionDtoImpl;

  factory _RedemptionDto.fromJson(Map<String, dynamic> json) =
      _$RedemptionDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get rewardId;
  @override
  int get xpCostSnapshot;
  @override
  String get status;
  @override // requested/approved/delivered/rejected/canceled
  Map<String, dynamic> get fulfillmentPayload;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RedemptionDtoImplCopyWith<_$RedemptionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedeemRewardResponseDto _$RedeemRewardResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _RedeemRewardResponseDto.fromJson(json);
}

/// @nodoc
mixin _$RedeemRewardResponseDto {
  RedemptionDto get redemption => throw _privateConstructorUsedError;
  int get xpBalanceAfter => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RedeemRewardResponseDtoCopyWith<RedeemRewardResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemRewardResponseDtoCopyWith<$Res> {
  factory $RedeemRewardResponseDtoCopyWith(RedeemRewardResponseDto value,
          $Res Function(RedeemRewardResponseDto) then) =
      _$RedeemRewardResponseDtoCopyWithImpl<$Res, RedeemRewardResponseDto>;
  @useResult
  $Res call({RedemptionDto redemption, int xpBalanceAfter});

  $RedemptionDtoCopyWith<$Res> get redemption;
}

/// @nodoc
class _$RedeemRewardResponseDtoCopyWithImpl<$Res,
        $Val extends RedeemRewardResponseDto>
    implements $RedeemRewardResponseDtoCopyWith<$Res> {
  _$RedeemRewardResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redemption = null,
    Object? xpBalanceAfter = null,
  }) {
    return _then(_value.copyWith(
      redemption: null == redemption
          ? _value.redemption
          : redemption // ignore: cast_nullable_to_non_nullable
              as RedemptionDto,
      xpBalanceAfter: null == xpBalanceAfter
          ? _value.xpBalanceAfter
          : xpBalanceAfter // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RedemptionDtoCopyWith<$Res> get redemption {
    return $RedemptionDtoCopyWith<$Res>(_value.redemption, (value) {
      return _then(_value.copyWith(redemption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RedeemRewardResponseDtoImplCopyWith<$Res>
    implements $RedeemRewardResponseDtoCopyWith<$Res> {
  factory _$$RedeemRewardResponseDtoImplCopyWith(
          _$RedeemRewardResponseDtoImpl value,
          $Res Function(_$RedeemRewardResponseDtoImpl) then) =
      __$$RedeemRewardResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RedemptionDto redemption, int xpBalanceAfter});

  @override
  $RedemptionDtoCopyWith<$Res> get redemption;
}

/// @nodoc
class __$$RedeemRewardResponseDtoImplCopyWithImpl<$Res>
    extends _$RedeemRewardResponseDtoCopyWithImpl<$Res,
        _$RedeemRewardResponseDtoImpl>
    implements _$$RedeemRewardResponseDtoImplCopyWith<$Res> {
  __$$RedeemRewardResponseDtoImplCopyWithImpl(
      _$RedeemRewardResponseDtoImpl _value,
      $Res Function(_$RedeemRewardResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redemption = null,
    Object? xpBalanceAfter = null,
  }) {
    return _then(_$RedeemRewardResponseDtoImpl(
      redemption: null == redemption
          ? _value.redemption
          : redemption // ignore: cast_nullable_to_non_nullable
              as RedemptionDto,
      xpBalanceAfter: null == xpBalanceAfter
          ? _value.xpBalanceAfter
          : xpBalanceAfter // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemRewardResponseDtoImpl implements _RedeemRewardResponseDto {
  const _$RedeemRewardResponseDtoImpl(
      {required this.redemption, required this.xpBalanceAfter});

  factory _$RedeemRewardResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemRewardResponseDtoImplFromJson(json);

  @override
  final RedemptionDto redemption;
  @override
  final int xpBalanceAfter;

  @override
  String toString() {
    return 'RedeemRewardResponseDto(redemption: $redemption, xpBalanceAfter: $xpBalanceAfter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemRewardResponseDtoImpl &&
            (identical(other.redemption, redemption) ||
                other.redemption == redemption) &&
            (identical(other.xpBalanceAfter, xpBalanceAfter) ||
                other.xpBalanceAfter == xpBalanceAfter));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, redemption, xpBalanceAfter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemRewardResponseDtoImplCopyWith<_$RedeemRewardResponseDtoImpl>
      get copyWith => __$$RedeemRewardResponseDtoImplCopyWithImpl<
          _$RedeemRewardResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemRewardResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _RedeemRewardResponseDto implements RedeemRewardResponseDto {
  const factory _RedeemRewardResponseDto(
      {required final RedemptionDto redemption,
      required final int xpBalanceAfter}) = _$RedeemRewardResponseDtoImpl;

  factory _RedeemRewardResponseDto.fromJson(Map<String, dynamic> json) =
      _$RedeemRewardResponseDtoImpl.fromJson;

  @override
  RedemptionDto get redemption;
  @override
  int get xpBalanceAfter;
  @override
  @JsonKey(ignore: true)
  _$$RedeemRewardResponseDtoImplCopyWith<_$RedeemRewardResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
