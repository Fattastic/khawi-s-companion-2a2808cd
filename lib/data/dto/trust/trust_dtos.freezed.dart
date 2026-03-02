// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trust_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrustStateDto _$TrustStateDtoFromJson(Map<String, dynamic> json) {
  return _TrustStateDto.fromJson(json);
}

/// @nodoc
mixin _$TrustStateDto {
  String get userId => throw _privateConstructorUsedError;
  String get tier =>
      throw _privateConstructorUsedError; // bronze/silver/gold/platinum
  double get score => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  Map<String, dynamic> get explain => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrustStateDtoCopyWith<TrustStateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustStateDtoCopyWith<$Res> {
  factory $TrustStateDtoCopyWith(
          TrustStateDto value, $Res Function(TrustStateDto) then) =
      _$TrustStateDtoCopyWithImpl<$Res, TrustStateDto>;
  @useResult
  $Res call(
      {String userId,
      String tier,
      double score,
      double confidence,
      Map<String, dynamic> explain,
      DateTime updatedAt});
}

/// @nodoc
class _$TrustStateDtoCopyWithImpl<$Res, $Val extends TrustStateDto>
    implements $TrustStateDtoCopyWith<$Res> {
  _$TrustStateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tier = null,
    Object? score = null,
    Object? confidence = null,
    Object? explain = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      explain: null == explain
          ? _value.explain
          : explain // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrustStateDtoImplCopyWith<$Res>
    implements $TrustStateDtoCopyWith<$Res> {
  factory _$$TrustStateDtoImplCopyWith(
          _$TrustStateDtoImpl value, $Res Function(_$TrustStateDtoImpl) then) =
      __$$TrustStateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String tier,
      double score,
      double confidence,
      Map<String, dynamic> explain,
      DateTime updatedAt});
}

/// @nodoc
class __$$TrustStateDtoImplCopyWithImpl<$Res>
    extends _$TrustStateDtoCopyWithImpl<$Res, _$TrustStateDtoImpl>
    implements _$$TrustStateDtoImplCopyWith<$Res> {
  __$$TrustStateDtoImplCopyWithImpl(
      _$TrustStateDtoImpl _value, $Res Function(_$TrustStateDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tier = null,
    Object? score = null,
    Object? confidence = null,
    Object? explain = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TrustStateDtoImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      explain: null == explain
          ? _value._explain
          : explain // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrustStateDtoImpl implements _TrustStateDto {
  const _$TrustStateDtoImpl(
      {required this.userId,
      required this.tier,
      required this.score,
      required this.confidence,
      final Map<String, dynamic> explain = const <String, dynamic>{},
      required this.updatedAt})
      : _explain = explain;

  factory _$TrustStateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrustStateDtoImplFromJson(json);

  @override
  final String userId;
  @override
  final String tier;
// bronze/silver/gold/platinum
  @override
  final double score;
  @override
  final double confidence;
  final Map<String, dynamic> _explain;
  @override
  @JsonKey()
  Map<String, dynamic> get explain {
    if (_explain is EqualUnmodifiableMapView) return _explain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_explain);
  }

  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TrustStateDto(userId: $userId, tier: $tier, score: $score, confidence: $confidence, explain: $explain, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustStateDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(other._explain, _explain) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, tier, score, confidence,
      const DeepCollectionEquality().hash(_explain), updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustStateDtoImplCopyWith<_$TrustStateDtoImpl> get copyWith =>
      __$$TrustStateDtoImplCopyWithImpl<_$TrustStateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrustStateDtoImplToJson(
      this,
    );
  }
}

abstract class _TrustStateDto implements TrustStateDto {
  const factory _TrustStateDto(
      {required final String userId,
      required final String tier,
      required final double score,
      required final double confidence,
      final Map<String, dynamic> explain,
      required final DateTime updatedAt}) = _$TrustStateDtoImpl;

  factory _TrustStateDto.fromJson(Map<String, dynamic> json) =
      _$TrustStateDtoImpl.fromJson;

  @override
  String get userId;
  @override
  String get tier;
  @override // bronze/silver/gold/platinum
  double get score;
  @override
  double get confidence;
  @override
  Map<String, dynamic> get explain;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TrustStateDtoImplCopyWith<_$TrustStateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetTrustStateResponseDto _$GetTrustStateResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _GetTrustStateResponseDto.fromJson(json);
}

/// @nodoc
mixin _$GetTrustStateResponseDto {
  TrustStateDto get trust => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetTrustStateResponseDtoCopyWith<GetTrustStateResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetTrustStateResponseDtoCopyWith<$Res> {
  factory $GetTrustStateResponseDtoCopyWith(GetTrustStateResponseDto value,
          $Res Function(GetTrustStateResponseDto) then) =
      _$GetTrustStateResponseDtoCopyWithImpl<$Res, GetTrustStateResponseDto>;
  @useResult
  $Res call({TrustStateDto trust});

  $TrustStateDtoCopyWith<$Res> get trust;
}

/// @nodoc
class _$GetTrustStateResponseDtoCopyWithImpl<$Res,
        $Val extends GetTrustStateResponseDto>
    implements $GetTrustStateResponseDtoCopyWith<$Res> {
  _$GetTrustStateResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trust = null,
  }) {
    return _then(_value.copyWith(
      trust: null == trust
          ? _value.trust
          : trust // ignore: cast_nullable_to_non_nullable
              as TrustStateDto,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TrustStateDtoCopyWith<$Res> get trust {
    return $TrustStateDtoCopyWith<$Res>(_value.trust, (value) {
      return _then(_value.copyWith(trust: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetTrustStateResponseDtoImplCopyWith<$Res>
    implements $GetTrustStateResponseDtoCopyWith<$Res> {
  factory _$$GetTrustStateResponseDtoImplCopyWith(
          _$GetTrustStateResponseDtoImpl value,
          $Res Function(_$GetTrustStateResponseDtoImpl) then) =
      __$$GetTrustStateResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TrustStateDto trust});

  @override
  $TrustStateDtoCopyWith<$Res> get trust;
}

/// @nodoc
class __$$GetTrustStateResponseDtoImplCopyWithImpl<$Res>
    extends _$GetTrustStateResponseDtoCopyWithImpl<$Res,
        _$GetTrustStateResponseDtoImpl>
    implements _$$GetTrustStateResponseDtoImplCopyWith<$Res> {
  __$$GetTrustStateResponseDtoImplCopyWithImpl(
      _$GetTrustStateResponseDtoImpl _value,
      $Res Function(_$GetTrustStateResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trust = null,
  }) {
    return _then(_$GetTrustStateResponseDtoImpl(
      trust: null == trust
          ? _value.trust
          : trust // ignore: cast_nullable_to_non_nullable
              as TrustStateDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetTrustStateResponseDtoImpl implements _GetTrustStateResponseDto {
  const _$GetTrustStateResponseDtoImpl({required this.trust});

  factory _$GetTrustStateResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetTrustStateResponseDtoImplFromJson(json);

  @override
  final TrustStateDto trust;

  @override
  String toString() {
    return 'GetTrustStateResponseDto(trust: $trust)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetTrustStateResponseDtoImpl &&
            (identical(other.trust, trust) || other.trust == trust));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, trust);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetTrustStateResponseDtoImplCopyWith<_$GetTrustStateResponseDtoImpl>
      get copyWith => __$$GetTrustStateResponseDtoImplCopyWithImpl<
          _$GetTrustStateResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetTrustStateResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _GetTrustStateResponseDto implements GetTrustStateResponseDto {
  const factory _GetTrustStateResponseDto(
      {required final TrustStateDto trust}) = _$GetTrustStateResponseDtoImpl;

  factory _GetTrustStateResponseDto.fromJson(Map<String, dynamic> json) =
      _$GetTrustStateResponseDtoImpl.fromJson;

  @override
  TrustStateDto get trust;
  @override
  @JsonKey(ignore: true)
  _$$GetTrustStateResponseDtoImplCopyWith<_$GetTrustStateResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TrustEventDto _$TrustEventDtoFromJson(Map<String, dynamic> json) {
  return _TrustEventDto.fromJson(json);
}

/// @nodoc
mixin _$TrustEventDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get actor => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String? get fromTier => throw _privateConstructorUsedError;
  String? get toTier => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrustEventDtoCopyWith<TrustEventDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustEventDtoCopyWith<$Res> {
  factory $TrustEventDtoCopyWith(
          TrustEventDto value, $Res Function(TrustEventDto) then) =
      _$TrustEventDtoCopyWithImpl<$Res, TrustEventDto>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String actor,
      String eventType,
      String? fromTier,
      String? toTier,
      Map<String, dynamic> payload,
      DateTime createdAt});
}

/// @nodoc
class _$TrustEventDtoCopyWithImpl<$Res, $Val extends TrustEventDto>
    implements $TrustEventDtoCopyWith<$Res> {
  _$TrustEventDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? actor = null,
    Object? eventType = null,
    Object? fromTier = freezed,
    Object? toTier = freezed,
    Object? payload = null,
    Object? createdAt = null,
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
      actor: null == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      fromTier: freezed == fromTier
          ? _value.fromTier
          : fromTier // ignore: cast_nullable_to_non_nullable
              as String?,
      toTier: freezed == toTier
          ? _value.toTier
          : toTier // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrustEventDtoImplCopyWith<$Res>
    implements $TrustEventDtoCopyWith<$Res> {
  factory _$$TrustEventDtoImplCopyWith(
          _$TrustEventDtoImpl value, $Res Function(_$TrustEventDtoImpl) then) =
      __$$TrustEventDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String actor,
      String eventType,
      String? fromTier,
      String? toTier,
      Map<String, dynamic> payload,
      DateTime createdAt});
}

/// @nodoc
class __$$TrustEventDtoImplCopyWithImpl<$Res>
    extends _$TrustEventDtoCopyWithImpl<$Res, _$TrustEventDtoImpl>
    implements _$$TrustEventDtoImplCopyWith<$Res> {
  __$$TrustEventDtoImplCopyWithImpl(
      _$TrustEventDtoImpl _value, $Res Function(_$TrustEventDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? actor = null,
    Object? eventType = null,
    Object? fromTier = freezed,
    Object? toTier = freezed,
    Object? payload = null,
    Object? createdAt = null,
  }) {
    return _then(_$TrustEventDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      actor: null == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      fromTier: freezed == fromTier
          ? _value.fromTier
          : fromTier // ignore: cast_nullable_to_non_nullable
              as String?,
      toTier: freezed == toTier
          ? _value.toTier
          : toTier // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrustEventDtoImpl implements _TrustEventDto {
  const _$TrustEventDtoImpl(
      {required this.id,
      required this.userId,
      required this.actor,
      required this.eventType,
      this.fromTier,
      this.toTier,
      final Map<String, dynamic> payload = const <String, dynamic>{},
      required this.createdAt})
      : _payload = payload;

  factory _$TrustEventDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrustEventDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String actor;
  @override
  final String eventType;
  @override
  final String? fromTier;
  @override
  final String? toTier;
  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TrustEventDto(id: $id, userId: $userId, actor: $actor, eventType: $eventType, fromTier: $fromTier, toTier: $toTier, payload: $payload, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustEventDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.fromTier, fromTier) ||
                other.fromTier == fromTier) &&
            (identical(other.toTier, toTier) || other.toTier == toTier) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      actor,
      eventType,
      fromTier,
      toTier,
      const DeepCollectionEquality().hash(_payload),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustEventDtoImplCopyWith<_$TrustEventDtoImpl> get copyWith =>
      __$$TrustEventDtoImplCopyWithImpl<_$TrustEventDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrustEventDtoImplToJson(
      this,
    );
  }
}

abstract class _TrustEventDto implements TrustEventDto {
  const factory _TrustEventDto(
      {required final String id,
      required final String userId,
      required final String actor,
      required final String eventType,
      final String? fromTier,
      final String? toTier,
      final Map<String, dynamic> payload,
      required final DateTime createdAt}) = _$TrustEventDtoImpl;

  factory _TrustEventDto.fromJson(Map<String, dynamic> json) =
      _$TrustEventDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get actor;
  @override
  String get eventType;
  @override
  String? get fromTier;
  @override
  String? get toTier;
  @override
  Map<String, dynamic> get payload;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TrustEventDtoImplCopyWith<_$TrustEventDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
