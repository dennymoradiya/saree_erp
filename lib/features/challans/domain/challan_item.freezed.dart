// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challan_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChallanItem _$ChallanItemFromJson(Map<String, dynamic> json) {
  return _ChallanItem.fromJson(json);
}

/// @nodoc
mixin _$ChallanItem {
  String get challanItemId => throw _privateConstructorUsedError;
  String get challanId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get sku =>
      throw _privateConstructorUsedError; // Snapshots — historical records must never change when the product
// master is edited later (§49).
  String get productNameSnapshot => throw _privateConstructorUsedError;
  String get skuSnapshot => throw _privateConstructorUsedError;
  String? get colorNameSnapshot =>
      throw _privateConstructorUsedError; // --- A. Stitching production state (finished saree) ---
  double get sareeIssuedQuantity => throw _privateConstructorUsedError;
  double get sareeReturnedQuantity => throw _privateConstructorUsedError;
  double get sareePendingQuantity =>
      throw _privateConstructorUsedError; // --- B. Supplier raw-material state, per component ---
  double get laceRequiredQuantity => throw _privateConstructorUsedError;
  double get laceSuppliedQuantity => throw _privateConstructorUsedError;
  double get lacePendingSupplierQuantity => throw _privateConstructorUsedError;
  double get blouseRequiredQuantity => throw _privateConstructorUsedError;
  double get blouseSuppliedQuantity => throw _privateConstructorUsedError;
  double get blousePendingSupplierQuantity =>
      throw _privateConstructorUsedError; // Saree-component supplier state (saree material itself can also be
// short-delivered even though it is usually 1:1 with the issued qty).
  double get sareeRequiredQuantity => throw _privateConstructorUsedError;
  double get sareeSuppliedQuantity => throw _privateConstructorUsedError;
  double get sareePendingSupplierQuantity => throw _privateConstructorUsedError;

  /// Convenience mirror of sareeReturnedQuantity kept for reporting;
  /// canonical source of truth is sareeReturnedQuantity above.
  double get stitchingReturnedQuantity => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChallanItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallanItemCopyWith<ChallanItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallanItemCopyWith<$Res> {
  factory $ChallanItemCopyWith(
          ChallanItem value, $Res Function(ChallanItem) then) =
      _$ChallanItemCopyWithImpl<$Res, ChallanItem>;
  @useResult
  $Res call(
      {String challanItemId,
      String challanId,
      String productId,
      String sku,
      String productNameSnapshot,
      String skuSnapshot,
      String? colorNameSnapshot,
      double sareeIssuedQuantity,
      double sareeReturnedQuantity,
      double sareePendingQuantity,
      double laceRequiredQuantity,
      double laceSuppliedQuantity,
      double lacePendingSupplierQuantity,
      double blouseRequiredQuantity,
      double blouseSuppliedQuantity,
      double blousePendingSupplierQuantity,
      double sareeRequiredQuantity,
      double sareeSuppliedQuantity,
      double sareePendingSupplierQuantity,
      double stitchingReturnedQuantity,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$ChallanItemCopyWithImpl<$Res, $Val extends ChallanItem>
    implements $ChallanItemCopyWith<$Res> {
  _$ChallanItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanItemId = null,
    Object? challanId = null,
    Object? productId = null,
    Object? sku = null,
    Object? productNameSnapshot = null,
    Object? skuSnapshot = null,
    Object? colorNameSnapshot = freezed,
    Object? sareeIssuedQuantity = null,
    Object? sareeReturnedQuantity = null,
    Object? sareePendingQuantity = null,
    Object? laceRequiredQuantity = null,
    Object? laceSuppliedQuantity = null,
    Object? lacePendingSupplierQuantity = null,
    Object? blouseRequiredQuantity = null,
    Object? blouseSuppliedQuantity = null,
    Object? blousePendingSupplierQuantity = null,
    Object? sareeRequiredQuantity = null,
    Object? sareeSuppliedQuantity = null,
    Object? sareePendingSupplierQuantity = null,
    Object? stitchingReturnedQuantity = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      productNameSnapshot: null == productNameSnapshot
          ? _value.productNameSnapshot
          : productNameSnapshot // ignore: cast_nullable_to_non_nullable
              as String,
      skuSnapshot: null == skuSnapshot
          ? _value.skuSnapshot
          : skuSnapshot // ignore: cast_nullable_to_non_nullable
              as String,
      colorNameSnapshot: freezed == colorNameSnapshot
          ? _value.colorNameSnapshot
          : colorNameSnapshot // ignore: cast_nullable_to_non_nullable
              as String?,
      sareeIssuedQuantity: null == sareeIssuedQuantity
          ? _value.sareeIssuedQuantity
          : sareeIssuedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeReturnedQuantity: null == sareeReturnedQuantity
          ? _value.sareeReturnedQuantity
          : sareeReturnedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareePendingQuantity: null == sareePendingQuantity
          ? _value.sareePendingQuantity
          : sareePendingQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      laceRequiredQuantity: null == laceRequiredQuantity
          ? _value.laceRequiredQuantity
          : laceRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      laceSuppliedQuantity: null == laceSuppliedQuantity
          ? _value.laceSuppliedQuantity
          : laceSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      lacePendingSupplierQuantity: null == lacePendingSupplierQuantity
          ? _value.lacePendingSupplierQuantity
          : lacePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blouseRequiredQuantity: null == blouseRequiredQuantity
          ? _value.blouseRequiredQuantity
          : blouseRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blouseSuppliedQuantity: null == blouseSuppliedQuantity
          ? _value.blouseSuppliedQuantity
          : blouseSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blousePendingSupplierQuantity: null == blousePendingSupplierQuantity
          ? _value.blousePendingSupplierQuantity
          : blousePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeRequiredQuantity: null == sareeRequiredQuantity
          ? _value.sareeRequiredQuantity
          : sareeRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeSuppliedQuantity: null == sareeSuppliedQuantity
          ? _value.sareeSuppliedQuantity
          : sareeSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareePendingSupplierQuantity: null == sareePendingSupplierQuantity
          ? _value.sareePendingSupplierQuantity
          : sareePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      stitchingReturnedQuantity: null == stitchingReturnedQuantity
          ? _value.stitchingReturnedQuantity
          : stitchingReturnedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
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
abstract class _$$ChallanItemImplCopyWith<$Res>
    implements $ChallanItemCopyWith<$Res> {
  factory _$$ChallanItemImplCopyWith(
          _$ChallanItemImpl value, $Res Function(_$ChallanItemImpl) then) =
      __$$ChallanItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challanItemId,
      String challanId,
      String productId,
      String sku,
      String productNameSnapshot,
      String skuSnapshot,
      String? colorNameSnapshot,
      double sareeIssuedQuantity,
      double sareeReturnedQuantity,
      double sareePendingQuantity,
      double laceRequiredQuantity,
      double laceSuppliedQuantity,
      double lacePendingSupplierQuantity,
      double blouseRequiredQuantity,
      double blouseSuppliedQuantity,
      double blousePendingSupplierQuantity,
      double sareeRequiredQuantity,
      double sareeSuppliedQuantity,
      double sareePendingSupplierQuantity,
      double stitchingReturnedQuantity,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$ChallanItemImplCopyWithImpl<$Res>
    extends _$ChallanItemCopyWithImpl<$Res, _$ChallanItemImpl>
    implements _$$ChallanItemImplCopyWith<$Res> {
  __$$ChallanItemImplCopyWithImpl(
      _$ChallanItemImpl _value, $Res Function(_$ChallanItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanItemId = null,
    Object? challanId = null,
    Object? productId = null,
    Object? sku = null,
    Object? productNameSnapshot = null,
    Object? skuSnapshot = null,
    Object? colorNameSnapshot = freezed,
    Object? sareeIssuedQuantity = null,
    Object? sareeReturnedQuantity = null,
    Object? sareePendingQuantity = null,
    Object? laceRequiredQuantity = null,
    Object? laceSuppliedQuantity = null,
    Object? lacePendingSupplierQuantity = null,
    Object? blouseRequiredQuantity = null,
    Object? blouseSuppliedQuantity = null,
    Object? blousePendingSupplierQuantity = null,
    Object? sareeRequiredQuantity = null,
    Object? sareeSuppliedQuantity = null,
    Object? sareePendingSupplierQuantity = null,
    Object? stitchingReturnedQuantity = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ChallanItemImpl(
      challanItemId: null == challanItemId
          ? _value.challanItemId
          : challanItemId // ignore: cast_nullable_to_non_nullable
              as String,
      challanId: null == challanId
          ? _value.challanId
          : challanId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      productNameSnapshot: null == productNameSnapshot
          ? _value.productNameSnapshot
          : productNameSnapshot // ignore: cast_nullable_to_non_nullable
              as String,
      skuSnapshot: null == skuSnapshot
          ? _value.skuSnapshot
          : skuSnapshot // ignore: cast_nullable_to_non_nullable
              as String,
      colorNameSnapshot: freezed == colorNameSnapshot
          ? _value.colorNameSnapshot
          : colorNameSnapshot // ignore: cast_nullable_to_non_nullable
              as String?,
      sareeIssuedQuantity: null == sareeIssuedQuantity
          ? _value.sareeIssuedQuantity
          : sareeIssuedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeReturnedQuantity: null == sareeReturnedQuantity
          ? _value.sareeReturnedQuantity
          : sareeReturnedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareePendingQuantity: null == sareePendingQuantity
          ? _value.sareePendingQuantity
          : sareePendingQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      laceRequiredQuantity: null == laceRequiredQuantity
          ? _value.laceRequiredQuantity
          : laceRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      laceSuppliedQuantity: null == laceSuppliedQuantity
          ? _value.laceSuppliedQuantity
          : laceSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      lacePendingSupplierQuantity: null == lacePendingSupplierQuantity
          ? _value.lacePendingSupplierQuantity
          : lacePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blouseRequiredQuantity: null == blouseRequiredQuantity
          ? _value.blouseRequiredQuantity
          : blouseRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blouseSuppliedQuantity: null == blouseSuppliedQuantity
          ? _value.blouseSuppliedQuantity
          : blouseSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      blousePendingSupplierQuantity: null == blousePendingSupplierQuantity
          ? _value.blousePendingSupplierQuantity
          : blousePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeRequiredQuantity: null == sareeRequiredQuantity
          ? _value.sareeRequiredQuantity
          : sareeRequiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareeSuppliedQuantity: null == sareeSuppliedQuantity
          ? _value.sareeSuppliedQuantity
          : sareeSuppliedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      sareePendingSupplierQuantity: null == sareePendingSupplierQuantity
          ? _value.sareePendingSupplierQuantity
          : sareePendingSupplierQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      stitchingReturnedQuantity: null == stitchingReturnedQuantity
          ? _value.stitchingReturnedQuantity
          : stitchingReturnedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
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
class _$ChallanItemImpl implements _ChallanItem {
  const _$ChallanItemImpl(
      {required this.challanItemId,
      required this.challanId,
      required this.productId,
      required this.sku,
      required this.productNameSnapshot,
      required this.skuSnapshot,
      this.colorNameSnapshot,
      required this.sareeIssuedQuantity,
      required this.sareeReturnedQuantity,
      required this.sareePendingQuantity,
      required this.laceRequiredQuantity,
      required this.laceSuppliedQuantity,
      required this.lacePendingSupplierQuantity,
      required this.blouseRequiredQuantity,
      required this.blouseSuppliedQuantity,
      required this.blousePendingSupplierQuantity,
      required this.sareeRequiredQuantity,
      required this.sareeSuppliedQuantity,
      required this.sareePendingSupplierQuantity,
      this.stitchingReturnedQuantity = 0,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt});

  factory _$ChallanItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallanItemImplFromJson(json);

  @override
  final String challanItemId;
  @override
  final String challanId;
  @override
  final String productId;
  @override
  final String sku;
// Snapshots — historical records must never change when the product
// master is edited later (§49).
  @override
  final String productNameSnapshot;
  @override
  final String skuSnapshot;
  @override
  final String? colorNameSnapshot;
// --- A. Stitching production state (finished saree) ---
  @override
  final double sareeIssuedQuantity;
  @override
  final double sareeReturnedQuantity;
  @override
  final double sareePendingQuantity;
// --- B. Supplier raw-material state, per component ---
  @override
  final double laceRequiredQuantity;
  @override
  final double laceSuppliedQuantity;
  @override
  final double lacePendingSupplierQuantity;
  @override
  final double blouseRequiredQuantity;
  @override
  final double blouseSuppliedQuantity;
  @override
  final double blousePendingSupplierQuantity;
// Saree-component supplier state (saree material itself can also be
// short-delivered even though it is usually 1:1 with the issued qty).
  @override
  final double sareeRequiredQuantity;
  @override
  final double sareeSuppliedQuantity;
  @override
  final double sareePendingSupplierQuantity;

  /// Convenience mirror of sareeReturnedQuantity kept for reporting;
  /// canonical source of truth is sareeReturnedQuantity above.
  @override
  @JsonKey()
  final double stitchingReturnedQuantity;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ChallanItem(challanItemId: $challanItemId, challanId: $challanId, productId: $productId, sku: $sku, productNameSnapshot: $productNameSnapshot, skuSnapshot: $skuSnapshot, colorNameSnapshot: $colorNameSnapshot, sareeIssuedQuantity: $sareeIssuedQuantity, sareeReturnedQuantity: $sareeReturnedQuantity, sareePendingQuantity: $sareePendingQuantity, laceRequiredQuantity: $laceRequiredQuantity, laceSuppliedQuantity: $laceSuppliedQuantity, lacePendingSupplierQuantity: $lacePendingSupplierQuantity, blouseRequiredQuantity: $blouseRequiredQuantity, blouseSuppliedQuantity: $blouseSuppliedQuantity, blousePendingSupplierQuantity: $blousePendingSupplierQuantity, sareeRequiredQuantity: $sareeRequiredQuantity, sareeSuppliedQuantity: $sareeSuppliedQuantity, sareePendingSupplierQuantity: $sareePendingSupplierQuantity, stitchingReturnedQuantity: $stitchingReturnedQuantity, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallanItemImpl &&
            (identical(other.challanItemId, challanItemId) ||
                other.challanItemId == challanItemId) &&
            (identical(other.challanId, challanId) ||
                other.challanId == challanId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.productNameSnapshot, productNameSnapshot) ||
                other.productNameSnapshot == productNameSnapshot) &&
            (identical(other.skuSnapshot, skuSnapshot) ||
                other.skuSnapshot == skuSnapshot) &&
            (identical(other.colorNameSnapshot, colorNameSnapshot) ||
                other.colorNameSnapshot == colorNameSnapshot) &&
            (identical(other.sareeIssuedQuantity, sareeIssuedQuantity) ||
                other.sareeIssuedQuantity == sareeIssuedQuantity) &&
            (identical(other.sareeReturnedQuantity, sareeReturnedQuantity) ||
                other.sareeReturnedQuantity == sareeReturnedQuantity) &&
            (identical(other.sareePendingQuantity, sareePendingQuantity) ||
                other.sareePendingQuantity == sareePendingQuantity) &&
            (identical(other.laceRequiredQuantity, laceRequiredQuantity) ||
                other.laceRequiredQuantity == laceRequiredQuantity) &&
            (identical(other.laceSuppliedQuantity, laceSuppliedQuantity) ||
                other.laceSuppliedQuantity == laceSuppliedQuantity) &&
            (identical(other.lacePendingSupplierQuantity,
                    lacePendingSupplierQuantity) ||
                other.lacePendingSupplierQuantity ==
                    lacePendingSupplierQuantity) &&
            (identical(other.blouseRequiredQuantity, blouseRequiredQuantity) ||
                other.blouseRequiredQuantity == blouseRequiredQuantity) &&
            (identical(other.blouseSuppliedQuantity, blouseSuppliedQuantity) ||
                other.blouseSuppliedQuantity == blouseSuppliedQuantity) &&
            (identical(other.blousePendingSupplierQuantity,
                    blousePendingSupplierQuantity) ||
                other.blousePendingSupplierQuantity ==
                    blousePendingSupplierQuantity) &&
            (identical(other.sareeRequiredQuantity, sareeRequiredQuantity) ||
                other.sareeRequiredQuantity == sareeRequiredQuantity) &&
            (identical(other.sareeSuppliedQuantity, sareeSuppliedQuantity) ||
                other.sareeSuppliedQuantity == sareeSuppliedQuantity) &&
            (identical(other.sareePendingSupplierQuantity,
                    sareePendingSupplierQuantity) ||
                other.sareePendingSupplierQuantity ==
                    sareePendingSupplierQuantity) &&
            (identical(other.stitchingReturnedQuantity,
                    stitchingReturnedQuantity) ||
                other.stitchingReturnedQuantity == stitchingReturnedQuantity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        challanItemId,
        challanId,
        productId,
        sku,
        productNameSnapshot,
        skuSnapshot,
        colorNameSnapshot,
        sareeIssuedQuantity,
        sareeReturnedQuantity,
        sareePendingQuantity,
        laceRequiredQuantity,
        laceSuppliedQuantity,
        lacePendingSupplierQuantity,
        blouseRequiredQuantity,
        blouseSuppliedQuantity,
        blousePendingSupplierQuantity,
        sareeRequiredQuantity,
        sareeSuppliedQuantity,
        sareePendingSupplierQuantity,
        stitchingReturnedQuantity,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of ChallanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallanItemImplCopyWith<_$ChallanItemImpl> get copyWith =>
      __$$ChallanItemImplCopyWithImpl<_$ChallanItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallanItemImplToJson(
      this,
    );
  }
}

abstract class _ChallanItem implements ChallanItem {
  const factory _ChallanItem(
          {required final String challanItemId,
          required final String challanId,
          required final String productId,
          required final String sku,
          required final String productNameSnapshot,
          required final String skuSnapshot,
          final String? colorNameSnapshot,
          required final double sareeIssuedQuantity,
          required final double sareeReturnedQuantity,
          required final double sareePendingQuantity,
          required final double laceRequiredQuantity,
          required final double laceSuppliedQuantity,
          required final double lacePendingSupplierQuantity,
          required final double blouseRequiredQuantity,
          required final double blouseSuppliedQuantity,
          required final double blousePendingSupplierQuantity,
          required final double sareeRequiredQuantity,
          required final double sareeSuppliedQuantity,
          required final double sareePendingSupplierQuantity,
          final double stitchingReturnedQuantity,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$ChallanItemImpl;

  factory _ChallanItem.fromJson(Map<String, dynamic> json) =
      _$ChallanItemImpl.fromJson;

  @override
  String get challanItemId;
  @override
  String get challanId;
  @override
  String get productId;
  @override
  String
      get sku; // Snapshots — historical records must never change when the product
// master is edited later (§49).
  @override
  String get productNameSnapshot;
  @override
  String get skuSnapshot;
  @override
  String?
      get colorNameSnapshot; // --- A. Stitching production state (finished saree) ---
  @override
  double get sareeIssuedQuantity;
  @override
  double get sareeReturnedQuantity;
  @override
  double
      get sareePendingQuantity; // --- B. Supplier raw-material state, per component ---
  @override
  double get laceRequiredQuantity;
  @override
  double get laceSuppliedQuantity;
  @override
  double get lacePendingSupplierQuantity;
  @override
  double get blouseRequiredQuantity;
  @override
  double get blouseSuppliedQuantity;
  @override
  double
      get blousePendingSupplierQuantity; // Saree-component supplier state (saree material itself can also be
// short-delivered even though it is usually 1:1 with the issued qty).
  @override
  double get sareeRequiredQuantity;
  @override
  double get sareeSuppliedQuantity;
  @override
  double get sareePendingSupplierQuantity;

  /// Convenience mirror of sareeReturnedQuantity kept for reporting;
  /// canonical source of truth is sareeReturnedQuantity above.
  @override
  double get stitchingReturnedQuantity;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of ChallanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallanItemImplCopyWith<_$ChallanItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
