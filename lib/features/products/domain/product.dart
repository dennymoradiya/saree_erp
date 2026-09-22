import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// products/{productId}
@freezed
class Product with _$Product {
  const factory Product({
    required String productId,
    required String name,
    required String productCode,
    String? description,
    required bool isActive,
    @Default(true) bool requiresSaree,
    @Default(true) bool requiresLace,
    @Default(true) bool requiresBlouse,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
