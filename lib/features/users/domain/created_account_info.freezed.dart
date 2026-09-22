// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'created_account_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatedAccountInfo _$CreatedAccountInfoFromJson(Map<String, dynamic> json) {
  return _CreatedAccountInfo.fromJson(json);
}

/// @nodoc
mixin _$CreatedAccountInfo {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get temporaryPassword => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get stitchingUserId => throw _privateConstructorUsedError;

  /// Serializes this CreatedAccountInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreatedAccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatedAccountInfoCopyWith<CreatedAccountInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatedAccountInfoCopyWith<$Res> {
  factory $CreatedAccountInfoCopyWith(
          CreatedAccountInfo value, $Res Function(CreatedAccountInfo) then) =
      _$CreatedAccountInfoCopyWithImpl<$Res, CreatedAccountInfo>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String temporaryPassword,
      String? supplierId,
      String? stitchingUserId});
}

/// @nodoc
class _$CreatedAccountInfoCopyWithImpl<$Res, $Val extends CreatedAccountInfo>
    implements $CreatedAccountInfoCopyWith<$Res> {
  _$CreatedAccountInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatedAccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? temporaryPassword = null,
    Object? supplierId = freezed,
    Object? stitchingUserId = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      temporaryPassword: null == temporaryPassword
          ? _value.temporaryPassword
          : temporaryPassword // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      stitchingUserId: freezed == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatedAccountInfoImplCopyWith<$Res>
    implements $CreatedAccountInfoCopyWith<$Res> {
  factory _$$CreatedAccountInfoImplCopyWith(_$CreatedAccountInfoImpl value,
          $Res Function(_$CreatedAccountInfoImpl) then) =
      __$$CreatedAccountInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String temporaryPassword,
      String? supplierId,
      String? stitchingUserId});
}

/// @nodoc
class __$$CreatedAccountInfoImplCopyWithImpl<$Res>
    extends _$CreatedAccountInfoCopyWithImpl<$Res, _$CreatedAccountInfoImpl>
    implements _$$CreatedAccountInfoImplCopyWith<$Res> {
  __$$CreatedAccountInfoImplCopyWithImpl(_$CreatedAccountInfoImpl _value,
      $Res Function(_$CreatedAccountInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatedAccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? temporaryPassword = null,
    Object? supplierId = freezed,
    Object? stitchingUserId = freezed,
  }) {
    return _then(_$CreatedAccountInfoImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      temporaryPassword: null == temporaryPassword
          ? _value.temporaryPassword
          : temporaryPassword // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      stitchingUserId: freezed == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatedAccountInfoImpl implements _CreatedAccountInfo {
  const _$CreatedAccountInfoImpl(
      {required this.uid,
      required this.email,
      required this.temporaryPassword,
      this.supplierId,
      this.stitchingUserId});

  factory _$CreatedAccountInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatedAccountInfoImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String temporaryPassword;
  @override
  final String? supplierId;
  @override
  final String? stitchingUserId;

  @override
  String toString() {
    return 'CreatedAccountInfo(uid: $uid, email: $email, temporaryPassword: $temporaryPassword, supplierId: $supplierId, stitchingUserId: $stitchingUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatedAccountInfoImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.temporaryPassword, temporaryPassword) ||
                other.temporaryPassword == temporaryPassword) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.stitchingUserId, stitchingUserId) ||
                other.stitchingUserId == stitchingUserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, uid, email, temporaryPassword, supplierId, stitchingUserId);

  /// Create a copy of CreatedAccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatedAccountInfoImplCopyWith<_$CreatedAccountInfoImpl> get copyWith =>
      __$$CreatedAccountInfoImplCopyWithImpl<_$CreatedAccountInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatedAccountInfoImplToJson(
      this,
    );
  }
}

abstract class _CreatedAccountInfo implements CreatedAccountInfo {
  const factory _CreatedAccountInfo(
      {required final String uid,
      required final String email,
      required final String temporaryPassword,
      final String? supplierId,
      final String? stitchingUserId}) = _$CreatedAccountInfoImpl;

  factory _CreatedAccountInfo.fromJson(Map<String, dynamic> json) =
      _$CreatedAccountInfoImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String get temporaryPassword;
  @override
  String? get supplierId;
  @override
  String? get stitchingUserId;

  /// Create a copy of CreatedAccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatedAccountInfoImplCopyWith<_$CreatedAccountInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
