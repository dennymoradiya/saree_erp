// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Challan _$ChallanFromJson(Map<String, dynamic> json) {
  return _Challan.fromJson(json);
}

/// @nodoc
mixin _$Challan {
  String get challanId => throw _privateConstructorUsedError;

  /// Human-readable sequence number, e.g. CH-2026-000001. Never the
  /// Firestore document id (§50).
  String get challanNumber => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String get stitchingUserId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get createdByRole => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  ChallanStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get issuedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get cancelledReason => throw _privateConstructorUsedError;
  String? get cancelledBy => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get cancelledAt => throw _privateConstructorUsedError;

  /// Serializes this Challan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Challan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallanCopyWith<Challan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallanCopyWith<$Res> {
  factory $ChallanCopyWith(Challan value, $Res Function(Challan) then) =
      _$ChallanCopyWithImpl<$Res, Challan>;
  @useResult
  $Res call(
      {String challanId,
      String challanNumber,
      String supplierId,
      String stitchingUserId,
      String createdBy,
      String createdByRole,
      @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
      ChallanStatus status,
      @TimestampConverter() DateTime issuedAt,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? notes,
      String? cancelledReason,
      String? cancelledBy,
      @NullableTimestampConverter() DateTime? cancelledAt});
}

/// @nodoc
class _$ChallanCopyWithImpl<$Res, $Val extends Challan>
    implements $ChallanCopyWith<$Res> {
  _$ChallanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Challan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanId = null,
    Object? challanNumber = null,
    Object? supplierId = null,
    Object? stitchingUserId = null,
    Object? createdBy = null,
    Object? createdByRole = null,
    Object? status = null,
    Object? issuedAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
    Object? cancelledReason = freezed,
    Object? cancelledBy = freezed,
    Object? cancelledAt = freezed,
  }) {
    return _then(_value.copyWith(
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanNumber: null == challanNumber
          ? _value.challanNumber
          : challanNumber // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdByRole: null == createdByRole
          ? _value.createdByRole
          : createdByRole // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChallanStatus,
      issuedAt: null == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledReason: freezed == cancelledReason
          ? _value.cancelledReason
          : cancelledReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallanImplCopyWith<$Res> implements $ChallanCopyWith<$Res> {
  factory _$$ChallanImplCopyWith(
          _$ChallanImpl value, $Res Function(_$ChallanImpl) then) =
      __$$ChallanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challanId,
      String challanNumber,
      String supplierId,
      String stitchingUserId,
      String createdBy,
      String createdByRole,
      @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
      ChallanStatus status,
      @TimestampConverter() DateTime issuedAt,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? notes,
      String? cancelledReason,
      String? cancelledBy,
      @NullableTimestampConverter() DateTime? cancelledAt});
}

/// @nodoc
class __$$ChallanImplCopyWithImpl<$Res>
    extends _$ChallanCopyWithImpl<$Res, _$ChallanImpl>
    implements _$$ChallanImplCopyWith<$Res> {
  __$$ChallanImplCopyWithImpl(
      _$ChallanImpl _value, $Res Function(_$ChallanImpl) _then)
      : super(_value, _then);

  /// Create a copy of Challan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanId = null,
    Object? challanNumber = null,
    Object? supplierId = null,
    Object? stitchingUserId = null,
    Object? createdBy = null,
    Object? createdByRole = null,
    Object? status = null,
    Object? issuedAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
    Object? cancelledReason = freezed,
    Object? cancelledBy = freezed,
    Object? cancelledAt = freezed,
  }) {
    return _then(_$ChallanImpl(
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanNumber: null == challanNumber
          ? _value.challanNumber
          : challanNumber // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdByRole: null == createdByRole
          ? _value.createdByRole
          : createdByRole // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChallanStatus,
      issuedAt: null == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledReason: freezed == cancelledReason
          ? _value.cancelledReason
          : cancelledReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallanImpl implements _Challan {
  const _$ChallanImpl(
      {required this.challanId,
      required this.challanNumber,
      required this.supplierId,
      required this.stitchingUserId,
      required this.createdBy,
      required this.createdByRole,
      @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
      required this.status,
      @TimestampConverter() required this.issuedAt,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      this.notes,
      this.cancelledReason,
      this.cancelledBy,
      @NullableTimestampConverter() this.cancelledAt});

  factory _$ChallanImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallanImplFromJson(json);

  @override
  final String challanId;

  /// Human-readable sequence number, e.g. CH-2026-000001. Never the
  /// Firestore document id (§50).
  @override
  final String challanNumber;
  @override
  final String supplierId;
  @override
  final String stitchingUserId;
  @override
  final String createdBy;
  @override
  final String createdByRole;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final ChallanStatus status;
  @override
  @TimestampConverter()
  final DateTime issuedAt;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String? notes;
  @override
  final String? cancelledReason;
  @override
  final String? cancelledBy;
  @override
  @NullableTimestampConverter()
  final DateTime? cancelledAt;

  @override
  String toString() {
    return 'Challan(challanId: $challanId, challanNumber: $challanNumber, supplierId: $supplierId, stitchingUserId: $stitchingUserId, createdBy: $createdBy, createdByRole: $createdByRole, status: $status, issuedAt: $issuedAt, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, cancelledReason: $cancelledReason, cancelledBy: $cancelledBy, cancelledAt: $cancelledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallanImpl &&
            (identical(other.challanId, challanId) ||
                other.challanId == challanId) &&
            (identical(other.challanNumber, challanNumber) ||
                other.challanNumber == challanNumber) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.stitchingUserId, stitchingUserId) ||
                other.stitchingUserId == stitchingUserId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByRole, createdByRole) ||
                other.createdByRole == createdByRole) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancelledReason, cancelledReason) ||
                other.cancelledReason == cancelledReason) &&
            (identical(other.cancelledBy, cancelledBy) ||
                other.cancelledBy == cancelledBy) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challanId,
      challanNumber,
      supplierId,
      stitchingUserId,
      createdBy,
      createdByRole,
      status,
      issuedAt,
      createdAt,
      updatedAt,
      notes,
      cancelledReason,
      cancelledBy,
      cancelledAt);

  /// Create a copy of Challan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallanImplCopyWith<_$ChallanImpl> get copyWith =>
      __$$ChallanImplCopyWithImpl<_$ChallanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallanImplToJson(
      this,
    );
  }
}

abstract class _Challan implements Challan {
  const factory _Challan(
          {required final String challanId,
          required final String challanNumber,
          required final String supplierId,
          required final String stitchingUserId,
          required final String createdBy,
          required final String createdByRole,
          @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
          required final ChallanStatus status,
          @TimestampConverter() required final DateTime issuedAt,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt,
          final String? notes,
          final String? cancelledReason,
          final String? cancelledBy,
          @NullableTimestampConverter() final DateTime? cancelledAt}) =
      _$ChallanImpl;

  factory _Challan.fromJson(Map<String, dynamic> json) = _$ChallanImpl.fromJson;

  @override
  String get challanId;

  /// Human-readable sequence number, e.g. CH-2026-000001. Never the
  /// Firestore document id (§50).
  @override
  String get challanNumber;
  @override
  String get supplierId;
  @override
  String get stitchingUserId;
  @override
  String get createdBy;
  @override
  String get createdByRole;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  ChallanStatus get status;
  @override
  @TimestampConverter()
  DateTime get issuedAt;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get notes;
  @override
  String? get cancelledReason;
  @override
  String? get cancelledBy;
  @override
  @NullableTimestampConverter()
  DateTime? get cancelledAt;

  /// Create a copy of Challan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallanImplCopyWith<_$ChallanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
