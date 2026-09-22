// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_material_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SupplierMaterialTransaction _$SupplierMaterialTransactionFromJson(
    Map<String, dynamic> json) {
  return _SupplierMaterialTransaction.fromJson(json);
}

/// @nodoc
mixin _$SupplierMaterialTransaction {
  String get transactionId => throw _privateConstructorUsedError;

  /// Groups all allocation rows produced by one physical delivery event.
  String get deliveryBatchId => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
  MaterialType get materialType => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  String get challanId => throw _privateConstructorUsedError;
  String get challanItemId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
  AllocationType get allocationType => throw _privateConstructorUsedError;

  /// When allocationType == oldPendingChallan, this is the id of the
  /// original challan item whose supplier-pending balance was reduced.
  String? get allocationReferenceId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this SupplierMaterialTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupplierMaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplierMaterialTransactionCopyWith<SupplierMaterialTransaction>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplierMaterialTransactionCopyWith<$Res> {
  factory $SupplierMaterialTransactionCopyWith(
          SupplierMaterialTransaction value,
          $Res Function(SupplierMaterialTransaction) then) =
      _$SupplierMaterialTransactionCopyWithImpl<$Res,
          SupplierMaterialTransaction>;
  @useResult
  $Res call(
      {String transactionId,
      String deliveryBatchId,
      String supplierId,
      String productId,
      String sku,
      @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
      MaterialType materialType,
      double quantity,
      String challanId,
      String challanItemId,
      @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
      AllocationType allocationType,
      String? allocationReferenceId,
      String createdBy,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class _$SupplierMaterialTransactionCopyWithImpl<$Res,
        $Val extends SupplierMaterialTransaction>
    implements $SupplierMaterialTransactionCopyWith<$Res> {
  _$SupplierMaterialTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplierMaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? deliveryBatchId = null,
    Object? supplierId = null,
    Object? productId = null,
    Object? sku = null,
    Object? materialType = null,
    Object? quantity = null,
    Object? challanId = null,
    Object? challanItemId = null,
    Object? allocationType = null,
    Object? allocationReferenceId = freezed,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryBatchId: null == deliveryBatchId
          ? _value.deliveryBatchId
          : deliveryBatchId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      materialType: null == materialType
          ? _value.materialType
          : materialType // ignore: cast_nullable_to_non_nullable
              as MaterialType,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      allocationType: null == allocationType
          ? _value.allocationType
          : allocationType // ignore: cast_nullable_to_non_nullable
              as AllocationType,
      allocationReferenceId: freezed == allocationReferenceId
          ? _value.allocationReferenceId
          : allocationReferenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SupplierMaterialTransactionImplCopyWith<$Res>
    implements $SupplierMaterialTransactionCopyWith<$Res> {
  factory _$$SupplierMaterialTransactionImplCopyWith(
          _$SupplierMaterialTransactionImpl value,
          $Res Function(_$SupplierMaterialTransactionImpl) then) =
      __$$SupplierMaterialTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String transactionId,
      String deliveryBatchId,
      String supplierId,
      String productId,
      String sku,
      @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
      MaterialType materialType,
      double quantity,
      String challanId,
      String challanItemId,
      @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
      AllocationType allocationType,
      String? allocationReferenceId,
      String createdBy,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class __$$SupplierMaterialTransactionImplCopyWithImpl<$Res>
    extends _$SupplierMaterialTransactionCopyWithImpl<$Res,
        _$SupplierMaterialTransactionImpl>
    implements _$$SupplierMaterialTransactionImplCopyWith<$Res> {
  __$$SupplierMaterialTransactionImplCopyWithImpl(
      _$SupplierMaterialTransactionImpl _value,
      $Res Function(_$SupplierMaterialTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupplierMaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? deliveryBatchId = null,
    Object? supplierId = null,
    Object? productId = null,
    Object? sku = null,
    Object? materialType = null,
    Object? quantity = null,
    Object? challanId = null,
    Object? challanItemId = null,
    Object? allocationType = null,
    Object? allocationReferenceId = freezed,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$SupplierMaterialTransactionImpl(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryBatchId: null == deliveryBatchId
          ? _value.deliveryBatchId
          : deliveryBatchId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      materialType: null == materialType
          ? _value.materialType
          : materialType // ignore: cast_nullable_to_non_nullable
              as MaterialType,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      allocationType: null == allocationType
          ? _value.allocationType
          : allocationType // ignore: cast_nullable_to_non_nullable
              as AllocationType,
      allocationReferenceId: freezed == allocationReferenceId
          ? _value.allocationReferenceId
          : allocationReferenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
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
class _$SupplierMaterialTransactionImpl
    implements _SupplierMaterialTransaction {
  const _$SupplierMaterialTransactionImpl(
      {required this.transactionId,
      required this.deliveryBatchId,
      required this.supplierId,
      required this.productId,
      required this.sku,
      @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
      required this.materialType,
      required this.quantity,
      required this.challanId,
      required this.challanItemId,
      @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
      required this.allocationType,
      this.allocationReferenceId,
      required this.createdBy,
      @TimestampConverter() required this.createdAt,
      this.notes});

  factory _$SupplierMaterialTransactionImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SupplierMaterialTransactionImplFromJson(json);

  @override
  final String transactionId;

  /// Groups all allocation rows produced by one physical delivery event.
  @override
  final String deliveryBatchId;
  @override
  final String supplierId;
  @override
  final String productId;
  @override
  final String sku;
  @override
  @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
  final MaterialType materialType;
  @override
  final double quantity;
  @override
  final String challanId;
  @override
  final String challanItemId;
  @override
  @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
  final AllocationType allocationType;

  /// When allocationType == oldPendingChallan, this is the id of the
  /// original challan item whose supplier-pending balance was reduced.
  @override
  final String? allocationReferenceId;
  @override
  final String createdBy;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'SupplierMaterialTransaction(transactionId: $transactionId, deliveryBatchId: $deliveryBatchId, supplierId: $supplierId, productId: $productId, sku: $sku, materialType: $materialType, quantity: $quantity, challanId: $challanId, challanItemId: $challanItemId, allocationType: $allocationType, allocationReferenceId: $allocationReferenceId, createdBy: $createdBy, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplierMaterialTransactionImpl &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.deliveryBatchId, deliveryBatchId) ||
                other.deliveryBatchId == deliveryBatchId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.materialType, materialType) ||
                other.materialType == materialType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.challanId, challanId) ||
                other.challanId == challanId) &&
            (identical(other.challanItemId, challanItemId) ||
                other.challanItemId == challanItemId) &&
            (identical(other.allocationType, allocationType) ||
                other.allocationType == allocationType) &&
            (identical(other.allocationReferenceId, allocationReferenceId) ||
                other.allocationReferenceId == allocationReferenceId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      transactionId,
      deliveryBatchId,
      supplierId,
      productId,
      sku,
      materialType,
      quantity,
      challanId,
      challanItemId,
      allocationType,
      allocationReferenceId,
      createdBy,
      createdAt,
      notes);

  /// Create a copy of SupplierMaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplierMaterialTransactionImplCopyWith<_$SupplierMaterialTransactionImpl>
      get copyWith => __$$SupplierMaterialTransactionImplCopyWithImpl<
          _$SupplierMaterialTransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplierMaterialTransactionImplToJson(
      this,
    );
  }
}

abstract class _SupplierMaterialTransaction
    implements SupplierMaterialTransaction {
  const factory _SupplierMaterialTransaction(
      {required final String transactionId,
      required final String deliveryBatchId,
      required final String supplierId,
      required final String productId,
      required final String sku,
      @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
      required final MaterialType materialType,
      required final double quantity,
      required final String challanId,
      required final String challanItemId,
      @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
      required final AllocationType allocationType,
      final String? allocationReferenceId,
      required final String createdBy,
      @TimestampConverter() required final DateTime createdAt,
      final String? notes}) = _$SupplierMaterialTransactionImpl;

  factory _SupplierMaterialTransaction.fromJson(Map<String, dynamic> json) =
      _$SupplierMaterialTransactionImpl.fromJson;

  @override
  String get transactionId;

  /// Groups all allocation rows produced by one physical delivery event.
  @override
  String get deliveryBatchId;
  @override
  String get supplierId;
  @override
  String get productId;
  @override
  String get sku;
  @override
  @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
  MaterialType get materialType;
  @override
  double get quantity;
  @override
  String get challanId;
  @override
  String get challanItemId;
  @override
  @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
  AllocationType get allocationType;

  /// When allocationType == oldPendingChallan, this is the id of the
  /// original challan item whose supplier-pending balance was reduced.
  @override
  String? get allocationReferenceId;
  @override
  String get createdBy;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of SupplierMaterialTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplierMaterialTransactionImplCopyWith<_$SupplierMaterialTransactionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
