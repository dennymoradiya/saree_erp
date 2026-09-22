// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_sku.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductSku _$ProductSkuFromJson(Map<String, dynamic> json) {
  return _ProductSku.fromJson(json);
}

/// @nodoc
mixin _$ProductSku {
  String get productId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get colorName => throw _privateConstructorUsedError;
  String? get colorCode => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ProductSku to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductSku
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductSkuCopyWith<ProductSku> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductSkuCopyWith<$Res> {
  factory $ProductSkuCopyWith(
          ProductSku value, $Res Function(ProductSku) then) =
      _$ProductSkuCopyWithImpl<$Res, ProductSku>;
  @useResult
  $Res call(
      {String productId,
      String sku,
      String colorName,
      String? colorCode,
      bool isActive});
}

/// @nodoc
class _$ProductSkuCopyWithImpl<$Res, $Val extends ProductSku>
    implements $ProductSkuCopyWith<$Res> {
  _$ProductSkuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductSku
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? colorName = null,
    Object? colorCode = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: freezed == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductSkuImplCopyWith<$Res>
    implements $ProductSkuCopyWith<$Res> {
  factory _$$ProductSkuImplCopyWith(
          _$ProductSkuImpl value, $Res Function(_$ProductSkuImpl) then) =
      __$$ProductSkuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String sku,
      String colorName,
      String? colorCode,
      bool isActive});
}

/// @nodoc
class __$$ProductSkuImplCopyWithImpl<$Res>
    extends _$ProductSkuCopyWithImpl<$Res, _$ProductSkuImpl>
    implements _$$ProductSkuImplCopyWith<$Res> {
  __$$ProductSkuImplCopyWithImpl(
      _$ProductSkuImpl _value, $Res Function(_$ProductSkuImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductSku
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? colorName = null,
    Object? colorCode = freezed,
    Object? isActive = null,
  }) {
    return _then(_$ProductSkuImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      colorName: null == colorName
          ? _value.colorName
          : colorName // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: freezed == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductSkuImpl extends _ProductSku {
  const _$ProductSkuImpl(
      {required this.productId,
      required this.sku,
      required this.colorName,
      this.colorCode,
      required this.isActive})
      : super._();

  factory _$ProductSkuImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductSkuImplFromJson(json);

  @override
  final String productId;
  @override
  final String sku;
  @override
  final String colorName;
  @override
  final String? colorCode;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'ProductSku(productId: $productId, sku: $sku, colorName: $colorName, colorCode: $colorCode, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductSkuImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, sku, colorName, colorCode, isActive);

  /// Create a copy of ProductSku
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductSkuImplCopyWith<_$ProductSkuImpl> get copyWith =>
      __$$ProductSkuImplCopyWithImpl<_$ProductSkuImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductSkuImplToJson(
      this,
    );
  }
}

abstract class _ProductSku extends ProductSku {
  const factory _ProductSku(
      {required final String productId,
      required final String sku,
      required final String colorName,
      final String? colorCode,
      required final bool isActive}) = _$ProductSkuImpl;
  const _ProductSku._() : super._();

  factory _ProductSku.fromJson(Map<String, dynamic> json) =
      _$ProductSkuImpl.fromJson;

  @override
  String get productId;
  @override
  String get sku;
  @override
  String get colorName;
  @override
  String? get colorCode;
  @override
  bool get isActive;

  /// Create a copy of ProductSku
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductSkuImplCopyWith<_$ProductSkuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
