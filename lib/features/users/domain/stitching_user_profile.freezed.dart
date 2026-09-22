// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stitching_user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StitchingUserProfile _$StitchingUserProfileFromJson(Map<String, dynamic> json) {
  return _StitchingUserProfile.fromJson(json);
}

/// @nodoc
mixin _$StitchingUserProfile {
  String get stitchingUserId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get linkedUserId => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StitchingUserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StitchingUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StitchingUserProfileCopyWith<StitchingUserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StitchingUserProfileCopyWith<$Res> {
  factory $StitchingUserProfileCopyWith(StitchingUserProfile value,
          $Res Function(StitchingUserProfile) then) =
      _$StitchingUserProfileCopyWithImpl<$Res, StitchingUserProfile>;
  @useResult
  $Res call(
      {String stitchingUserId,
      String name,
      String? linkedUserId,
      String? phone,
      String? address,
      bool isActive,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$StitchingUserProfileCopyWithImpl<$Res,
        $Val extends StitchingUserProfile>
    implements $StitchingUserProfileCopyWith<$Res> {
  _$StitchingUserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StitchingUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stitchingUserId = null,
    Object? name = null,
    Object? linkedUserId = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      linkedUserId: freezed == linkedUserId
          ? _value.linkedUserId
          : linkedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$StitchingUserProfileImplCopyWith<$Res>
    implements $StitchingUserProfileCopyWith<$Res> {
  factory _$$StitchingUserProfileImplCopyWith(_$StitchingUserProfileImpl value,
          $Res Function(_$StitchingUserProfileImpl) then) =
      __$$StitchingUserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stitchingUserId,
      String name,
      String? linkedUserId,
      String? phone,
      String? address,
      bool isActive,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$StitchingUserProfileImplCopyWithImpl<$Res>
    extends _$StitchingUserProfileCopyWithImpl<$Res, _$StitchingUserProfileImpl>
    implements _$$StitchingUserProfileImplCopyWith<$Res> {
  __$$StitchingUserProfileImplCopyWithImpl(_$StitchingUserProfileImpl _value,
      $Res Function(_$StitchingUserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of StitchingUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stitchingUserId = null,
    Object? name = null,
    Object? linkedUserId = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StitchingUserProfileImpl(
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      linkedUserId: freezed == linkedUserId
          ? _value.linkedUserId
          : linkedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$StitchingUserProfileImpl implements _StitchingUserProfile {
  const _$StitchingUserProfileImpl(
      {required this.stitchingUserId,
      required this.name,
      this.linkedUserId,
      this.phone,
      this.address,
      required this.isActive,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt});

  factory _$StitchingUserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$StitchingUserProfileImplFromJson(json);

  @override
  final String stitchingUserId;
  @override
  final String name;
  @override
  final String? linkedUserId;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  final bool isActive;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StitchingUserProfile(stitchingUserId: $stitchingUserId, name: $name, linkedUserId: $linkedUserId, phone: $phone, address: $address, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StitchingUserProfileImpl &&
            (identical(other.stitchingUserId, stitchingUserId) ||
                other.stitchingUserId == stitchingUserId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.linkedUserId, linkedUserId) ||
                other.linkedUserId == linkedUserId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stitchingUserId, name,
      linkedUserId, phone, address, isActive, createdAt, updatedAt);

  /// Create a copy of StitchingUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StitchingUserProfileImplCopyWith<_$StitchingUserProfileImpl>
      get copyWith =>
          __$$StitchingUserProfileImplCopyWithImpl<_$StitchingUserProfileImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StitchingUserProfileImplToJson(
      this,
    );
  }
}

abstract class _StitchingUserProfile implements StitchingUserProfile {
  const factory _StitchingUserProfile(
          {required final String stitchingUserId,
          required final String name,
          final String? linkedUserId,
          final String? phone,
          final String? address,
          required final bool isActive,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$StitchingUserProfileImpl;

  factory _StitchingUserProfile.fromJson(Map<String, dynamic> json) =
      _$StitchingUserProfileImpl.fromJson;

  @override
  String get stitchingUserId;
  @override
  String get name;
  @override
  String? get linkedUserId;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  bool get isActive;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of StitchingUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StitchingUserProfileImplCopyWith<_$StitchingUserProfileImpl>
      get copyWith => throw _privateConstructorUsedError;
}
