// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BadgeDto _$BadgeDtoFromJson(Map<String, dynamic> json) {
  return _BadgeDto.fromJson(json);
}

/// @nodoc
mixin _$BadgeDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get titleKey => throw _privateConstructorUsedError;
  String get descriptionKey => throw _privateConstructorUsedError;
  String get visibility =>
      throw _privateConstructorUsedError; // public/private/kids_only
  bool get isActive => throw _privateConstructorUsedError;
  Map<String, dynamic> get criteria => throw _privateConstructorUsedError;
  String? get iconAsset => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeDtoCopyWith<BadgeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeDtoCopyWith<$Res> {
  factory $BadgeDtoCopyWith(BadgeDto value, $Res Function(BadgeDto) then) =
      _$BadgeDtoCopyWithImpl<$Res, BadgeDto>;
  @useResult
  $Res call(
      {String id,
      String code,
      String titleKey,
      String descriptionKey,
      String visibility,
      bool isActive,
      Map<String, dynamic> criteria,
      String? iconAsset});
}

/// @nodoc
class _$BadgeDtoCopyWithImpl<$Res, $Val extends BadgeDto>
    implements $BadgeDtoCopyWith<$Res> {
  _$BadgeDtoCopyWithImpl(this._value, this._then);

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
    Object? visibility = null,
    Object? isActive = null,
    Object? criteria = null,
    Object? iconAsset = freezed,
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
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      criteria: null == criteria
          ? _value.criteria
          : criteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      iconAsset: freezed == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeDtoImplCopyWith<$Res>
    implements $BadgeDtoCopyWith<$Res> {
  factory _$$BadgeDtoImplCopyWith(
          _$BadgeDtoImpl value, $Res Function(_$BadgeDtoImpl) then) =
      __$$BadgeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String titleKey,
      String descriptionKey,
      String visibility,
      bool isActive,
      Map<String, dynamic> criteria,
      String? iconAsset});
}

/// @nodoc
class __$$BadgeDtoImplCopyWithImpl<$Res>
    extends _$BadgeDtoCopyWithImpl<$Res, _$BadgeDtoImpl>
    implements _$$BadgeDtoImplCopyWith<$Res> {
  __$$BadgeDtoImplCopyWithImpl(
      _$BadgeDtoImpl _value, $Res Function(_$BadgeDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? visibility = null,
    Object? isActive = null,
    Object? criteria = null,
    Object? iconAsset = freezed,
  }) {
    return _then(_$BadgeDtoImpl(
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
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      criteria: null == criteria
          ? _value._criteria
          : criteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      iconAsset: freezed == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeDtoImpl implements _BadgeDto {
  const _$BadgeDtoImpl(
      {required this.id,
      required this.code,
      required this.titleKey,
      required this.descriptionKey,
      required this.visibility,
      required this.isActive,
      final Map<String, dynamic> criteria = const <String, dynamic>{},
      this.iconAsset})
      : _criteria = criteria;

  factory _$BadgeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String titleKey;
  @override
  final String descriptionKey;
  @override
  final String visibility;
// public/private/kids_only
  @override
  final bool isActive;
  final Map<String, dynamic> _criteria;
  @override
  @JsonKey()
  Map<String, dynamic> get criteria {
    if (_criteria is EqualUnmodifiableMapView) return _criteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_criteria);
  }

  @override
  final String? iconAsset;

  @override
  String toString() {
    return 'BadgeDto(id: $id, code: $code, titleKey: $titleKey, descriptionKey: $descriptionKey, visibility: $visibility, isActive: $isActive, criteria: $criteria, iconAsset: $iconAsset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.titleKey, titleKey) ||
                other.titleKey == titleKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._criteria, _criteria) &&
            (identical(other.iconAsset, iconAsset) ||
                other.iconAsset == iconAsset));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      titleKey,
      descriptionKey,
      visibility,
      isActive,
      const DeepCollectionEquality().hash(_criteria),
      iconAsset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeDtoImplCopyWith<_$BadgeDtoImpl> get copyWith =>
      __$$BadgeDtoImplCopyWithImpl<_$BadgeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeDtoImplToJson(
      this,
    );
  }
}

abstract class _BadgeDto implements BadgeDto {
  const factory _BadgeDto(
      {required final String id,
      required final String code,
      required final String titleKey,
      required final String descriptionKey,
      required final String visibility,
      required final bool isActive,
      final Map<String, dynamic> criteria,
      final String? iconAsset}) = _$BadgeDtoImpl;

  factory _BadgeDto.fromJson(Map<String, dynamic> json) =
      _$BadgeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get titleKey;
  @override
  String get descriptionKey;
  @override
  String get visibility;
  @override // public/private/kids_only
  bool get isActive;
  @override
  Map<String, dynamic> get criteria;
  @override
  String? get iconAsset;
  @override
  @JsonKey(ignore: true)
  _$$BadgeDtoImplCopyWith<_$BadgeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserBadgeDto _$UserBadgeDtoFromJson(Map<String, dynamic> json) {
  return _UserBadgeDto.fromJson(json);
}

/// @nodoc
mixin _$UserBadgeDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get badgeId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError; // earned/revoked
  DateTime get earnedAt => throw _privateConstructorUsedError;
  DateTime? get revokedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get evidence => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserBadgeDtoCopyWith<UserBadgeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserBadgeDtoCopyWith<$Res> {
  factory $UserBadgeDtoCopyWith(
          UserBadgeDto value, $Res Function(UserBadgeDto) then) =
      _$UserBadgeDtoCopyWithImpl<$Res, UserBadgeDto>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String badgeId,
      String status,
      DateTime earnedAt,
      DateTime? revokedAt,
      Map<String, dynamic> evidence});
}

/// @nodoc
class _$UserBadgeDtoCopyWithImpl<$Res, $Val extends UserBadgeDto>
    implements $UserBadgeDtoCopyWith<$Res> {
  _$UserBadgeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeId = null,
    Object? status = null,
    Object? earnedAt = null,
    Object? revokedAt = freezed,
    Object? evidence = null,
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
      badgeId: null == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      earnedAt: null == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      evidence: null == evidence
          ? _value.evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserBadgeDtoImplCopyWith<$Res>
    implements $UserBadgeDtoCopyWith<$Res> {
  factory _$$UserBadgeDtoImplCopyWith(
          _$UserBadgeDtoImpl value, $Res Function(_$UserBadgeDtoImpl) then) =
      __$$UserBadgeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String badgeId,
      String status,
      DateTime earnedAt,
      DateTime? revokedAt,
      Map<String, dynamic> evidence});
}

/// @nodoc
class __$$UserBadgeDtoImplCopyWithImpl<$Res>
    extends _$UserBadgeDtoCopyWithImpl<$Res, _$UserBadgeDtoImpl>
    implements _$$UserBadgeDtoImplCopyWith<$Res> {
  __$$UserBadgeDtoImplCopyWithImpl(
      _$UserBadgeDtoImpl _value, $Res Function(_$UserBadgeDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeId = null,
    Object? status = null,
    Object? earnedAt = null,
    Object? revokedAt = freezed,
    Object? evidence = null,
  }) {
    return _then(_$UserBadgeDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      badgeId: null == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      earnedAt: null == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      evidence: null == evidence
          ? _value._evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserBadgeDtoImpl implements _UserBadgeDto {
  const _$UserBadgeDtoImpl(
      {required this.id,
      required this.userId,
      required this.badgeId,
      required this.status,
      required this.earnedAt,
      this.revokedAt,
      final Map<String, dynamic> evidence = const <String, dynamic>{}})
      : _evidence = evidence;

  factory _$UserBadgeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserBadgeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String badgeId;
  @override
  final String status;
// earned/revoked
  @override
  final DateTime earnedAt;
  @override
  final DateTime? revokedAt;
  final Map<String, dynamic> _evidence;
  @override
  @JsonKey()
  Map<String, dynamic> get evidence {
    if (_evidence is EqualUnmodifiableMapView) return _evidence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_evidence);
  }

  @override
  String toString() {
    return 'UserBadgeDto(id: $id, userId: $userId, badgeId: $badgeId, status: $status, earnedAt: $earnedAt, revokedAt: $revokedAt, evidence: $evidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserBadgeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            (identical(other.revokedAt, revokedAt) ||
                other.revokedAt == revokedAt) &&
            const DeepCollectionEquality().equals(other._evidence, _evidence));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, badgeId, status,
      earnedAt, revokedAt, const DeepCollectionEquality().hash(_evidence));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserBadgeDtoImplCopyWith<_$UserBadgeDtoImpl> get copyWith =>
      __$$UserBadgeDtoImplCopyWithImpl<_$UserBadgeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserBadgeDtoImplToJson(
      this,
    );
  }
}

abstract class _UserBadgeDto implements UserBadgeDto {
  const factory _UserBadgeDto(
      {required final String id,
      required final String userId,
      required final String badgeId,
      required final String status,
      required final DateTime earnedAt,
      final DateTime? revokedAt,
      final Map<String, dynamic> evidence}) = _$UserBadgeDtoImpl;

  factory _UserBadgeDto.fromJson(Map<String, dynamic> json) =
      _$UserBadgeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get badgeId;
  @override
  String get status;
  @override // earned/revoked
  DateTime get earnedAt;
  @override
  DateTime? get revokedAt;
  @override
  Map<String, dynamic> get evidence;
  @override
  @JsonKey(ignore: true)
  _$$UserBadgeDtoImplCopyWith<_$UserBadgeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListUserBadgesResponseDto _$ListUserBadgesResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _ListUserBadgesResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ListUserBadgesResponseDto {
  List<BadgeDto> get badgesCatalog => throw _privateConstructorUsedError;
  List<UserBadgeDto> get userBadges => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ListUserBadgesResponseDtoCopyWith<ListUserBadgesResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListUserBadgesResponseDtoCopyWith<$Res> {
  factory $ListUserBadgesResponseDtoCopyWith(ListUserBadgesResponseDto value,
          $Res Function(ListUserBadgesResponseDto) then) =
      _$ListUserBadgesResponseDtoCopyWithImpl<$Res, ListUserBadgesResponseDto>;
  @useResult
  $Res call({List<BadgeDto> badgesCatalog, List<UserBadgeDto> userBadges});
}

/// @nodoc
class _$ListUserBadgesResponseDtoCopyWithImpl<$Res,
        $Val extends ListUserBadgesResponseDto>
    implements $ListUserBadgesResponseDtoCopyWith<$Res> {
  _$ListUserBadgesResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgesCatalog = null,
    Object? userBadges = null,
  }) {
    return _then(_value.copyWith(
      badgesCatalog: null == badgesCatalog
          ? _value.badgesCatalog
          : badgesCatalog // ignore: cast_nullable_to_non_nullable
              as List<BadgeDto>,
      userBadges: null == userBadges
          ? _value.userBadges
          : userBadges // ignore: cast_nullable_to_non_nullable
              as List<UserBadgeDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListUserBadgesResponseDtoImplCopyWith<$Res>
    implements $ListUserBadgesResponseDtoCopyWith<$Res> {
  factory _$$ListUserBadgesResponseDtoImplCopyWith(
          _$ListUserBadgesResponseDtoImpl value,
          $Res Function(_$ListUserBadgesResponseDtoImpl) then) =
      __$$ListUserBadgesResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BadgeDto> badgesCatalog, List<UserBadgeDto> userBadges});
}

/// @nodoc
class __$$ListUserBadgesResponseDtoImplCopyWithImpl<$Res>
    extends _$ListUserBadgesResponseDtoCopyWithImpl<$Res,
        _$ListUserBadgesResponseDtoImpl>
    implements _$$ListUserBadgesResponseDtoImplCopyWith<$Res> {
  __$$ListUserBadgesResponseDtoImplCopyWithImpl(
      _$ListUserBadgesResponseDtoImpl _value,
      $Res Function(_$ListUserBadgesResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgesCatalog = null,
    Object? userBadges = null,
  }) {
    return _then(_$ListUserBadgesResponseDtoImpl(
      badgesCatalog: null == badgesCatalog
          ? _value._badgesCatalog
          : badgesCatalog // ignore: cast_nullable_to_non_nullable
              as List<BadgeDto>,
      userBadges: null == userBadges
          ? _value._userBadges
          : userBadges // ignore: cast_nullable_to_non_nullable
              as List<UserBadgeDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListUserBadgesResponseDtoImpl implements _ListUserBadgesResponseDto {
  const _$ListUserBadgesResponseDtoImpl(
      {required final List<BadgeDto> badgesCatalog,
      required final List<UserBadgeDto> userBadges})
      : _badgesCatalog = badgesCatalog,
        _userBadges = userBadges;

  factory _$ListUserBadgesResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListUserBadgesResponseDtoImplFromJson(json);

  final List<BadgeDto> _badgesCatalog;
  @override
  List<BadgeDto> get badgesCatalog {
    if (_badgesCatalog is EqualUnmodifiableListView) return _badgesCatalog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badgesCatalog);
  }

  final List<UserBadgeDto> _userBadges;
  @override
  List<UserBadgeDto> get userBadges {
    if (_userBadges is EqualUnmodifiableListView) return _userBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userBadges);
  }

  @override
  String toString() {
    return 'ListUserBadgesResponseDto(badgesCatalog: $badgesCatalog, userBadges: $userBadges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListUserBadgesResponseDtoImpl &&
            const DeepCollectionEquality()
                .equals(other._badgesCatalog, _badgesCatalog) &&
            const DeepCollectionEquality()
                .equals(other._userBadges, _userBadges));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_badgesCatalog),
      const DeepCollectionEquality().hash(_userBadges));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ListUserBadgesResponseDtoImplCopyWith<_$ListUserBadgesResponseDtoImpl>
      get copyWith => __$$ListUserBadgesResponseDtoImplCopyWithImpl<
          _$ListUserBadgesResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListUserBadgesResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _ListUserBadgesResponseDto implements ListUserBadgesResponseDto {
  const factory _ListUserBadgesResponseDto(
          {required final List<BadgeDto> badgesCatalog,
          required final List<UserBadgeDto> userBadges}) =
      _$ListUserBadgesResponseDtoImpl;

  factory _ListUserBadgesResponseDto.fromJson(Map<String, dynamic> json) =
      _$ListUserBadgesResponseDtoImpl.fromJson;

  @override
  List<BadgeDto> get badgesCatalog;
  @override
  List<UserBadgeDto> get userBadges;
  @override
  @JsonKey(ignore: true)
  _$$ListUserBadgesResponseDtoImplCopyWith<_$ListUserBadgesResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
