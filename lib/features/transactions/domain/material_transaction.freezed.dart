// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MaterialTransaction _$MaterialTransactionFromJson(Map<String, dynamic> json) {
  return _MaterialTransaction.fromJson(json);
}

/// @nodoc
mixin _$MaterialTransaction {
  String get transactionId => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get challanId => throw _privateConstructorUsedError;
  String get challanItemId => throw _privateConstructorUsedError;
  String get stitchingUserId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;

  /// Links a RETURN_APPROVED transaction back to its originating request.
  String? get depositRequestId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get createdByRole => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this MaterialTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaterialTransactionCopyWith<MaterialTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaterialTransactionCopyWith<$Res> {
  factory $MaterialTransactionCopyWith(
          MaterialTransaction value, $Res Function(MaterialTransaction) then) =
      _$MaterialTransactionCopyWithImpl<$Res, MaterialTransaction>;
  @useResult
  $Res call(
      {String transactionId,
      TransactionType type,
      String challanId,
      String challanItemId,
      String stitchingUserId,
      String productId,
      String sku,
      double quantity,
      String? depositRequestId,
      String createdBy,
      String createdByRole,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class _$MaterialTransactionCopyWithImpl<$Res, $Val extends MaterialTransaction>
    implements $MaterialTransactionCopyWith<$Res> {
  _$MaterialTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? type = null,
    Object? challanId = null,
    Object? challanItemId = null,
    Object? stitchingUserId = null,
    Object? productId = null,
    Object? sku = null,
    Object? quantity = null,
    Object? depositRequestId = freezed,
    Object? createdBy = null,
    Object? createdByRole = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      depositRequestId: freezed == depositRequestId
          ? _value.depositRequestId
          : depositRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdByRole: null == createdByRole
          ? _value.createdByRole
          : createdByRole // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MaterialTransactionImplCopyWith<$Res>
    implements $MaterialTransactionCopyWith<$Res> {
  factory _$$MaterialTransactionImplCopyWith(_$MaterialTransactionImpl value,
          $Res Function(_$MaterialTransactionImpl) then) =
      __$$MaterialTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String transactionId,
      TransactionType type,
      String challanId,
      String challanItemId,
      String stitchingUserId,
      String productId,
      String sku,
      double quantity,
      String? depositRequestId,
      String createdBy,
      String createdByRole,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class __$$MaterialTransactionImplCopyWithImpl<$Res>
    extends _$MaterialTransactionCopyWithImpl<$Res, _$MaterialTransactionImpl>
    implements _$$MaterialTransactionImplCopyWith<$Res> {
  __$$MaterialTransactionImplCopyWithImpl(_$MaterialTransactionImpl _value,
      $Res Function(_$MaterialTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of MaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? type = null,
    Object? challanId = null,
    Object? challanItemId = null,
    Object? stitchingUserId = null,
    Object? productId = null,
    Object? sku = null,
    Object? quantity = null,
    Object? depositRequestId = freezed,
    Object? createdBy = null,
    Object? createdByRole = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$MaterialTransactionImpl(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      stitchingUserId: null == stitchingUserId
          ? _value.stitchingUserId
          : stitchingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      depositRequestId: freezed == depositRequestId
          ? _value.depositRequestId
          : depositRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdByRole: null == createdByRole
          ? _value.createdByRole
          : createdByRole // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MaterialTransactionImpl implements _MaterialTransaction {
  const _$MaterialTransactionImpl(
      {required this.transactionId,
      required this.type,
      required this.challanId,
      required this.challanItemId,
      required this.stitchingUserId,
      required this.productId,
      required this.sku,
      required this.quantity,
      this.depositRequestId,
      required this.createdBy,
      required this.createdByRole,
      @TimestampConverter() required this.createdAt,
      this.notes});

  factory _$MaterialTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialTransactionImplFromJson(json);

  @override
  final String transactionId;
  @override
  final TransactionType type;
  @override
  final String challanId;
  @override
  final String challanItemId;
  @override
  final String stitchingUserId;
  @override
  final String productId;
  @override
  final String sku;
  @override
  final double quantity;

  /// Links a RETURN_APPROVED transaction back to its originating request.
  @override
  final String? depositRequestId;
  @override
  final String createdBy;
  @override
  final String createdByRole;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MaterialTransaction(transactionId: $transactionId, type: $type, challanId: $challanId, challanItemId: $challanItemId, stitchingUserId: $stitchingUserId, productId: $productId, sku: $sku, quantity: $quantity, depositRequestId: $depositRequestId, createdBy: $createdBy, createdByRole: $createdByRole, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialTransactionImpl &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.challanId, challanId) ||
                other.challanId == challanId) &&
            (identical(other.challanItemId, challanItemId) ||
                other.challanItemId == challanItemId) &&
            (identical(other.stitchingUserId, stitchingUserId) ||
                other.stitchingUserId == stitchingUserId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.depositRequestId, depositRequestId) ||
                other.depositRequestId == depositRequestId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByRole, createdByRole) ||
                other.createdByRole == createdByRole) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      transactionId,
      type,
      challanId,
      challanItemId,
      stitchingUserId,
      productId,
      sku,
      quantity,
      depositRequestId,
      createdBy,
      createdByRole,
      createdAt,
      notes);

  /// Create a copy of MaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialTransactionImplCopyWith<_$MaterialTransactionImpl> get copyWith =>
      __$$MaterialTransactionImplCopyWithImpl<_$MaterialTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaterialTransactionImplToJson(
      this,
    );
  }
}

abstract class _MaterialTransaction implements MaterialTransaction {
  const factory _MaterialTransaction(
      {required final String transactionId,
      required final TransactionType type,
      required final String challanId,
      required final String challanItemId,
      required final String stitchingUserId,
      required final String productId,
      required final String sku,
      required final double quantity,
      final String? depositRequestId,
      required final String createdBy,
      required final String createdByRole,
      @TimestampConverter() required final DateTime createdAt,
      final String? notes}) = _$MaterialTransactionImpl;

  factory _MaterialTransaction.fromJson(Map<String, dynamic> json) =
      _$MaterialTransactionImpl.fromJson;

  @override
  String get transactionId;
  @override
  TransactionType get type;
  @override
  String get challanId;
  @override
  String get challanItemId;
  @override
  String get stitchingUserId;
  @override
  String get productId;
  @override
  String get sku;
  @override
  double get quantity;

  /// Links a RETURN_APPROVED transaction back to its originating request.
  @override
  String? get depositRequestId;
  @override
  String get createdBy;
  @override
  String get createdByRole;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of MaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialTransactionImplCopyWith<_$MaterialTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
