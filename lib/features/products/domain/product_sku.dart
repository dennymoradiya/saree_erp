import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_sku.freezed.dart';
part 'product_sku.g.dart';

/// products/{productId}/skus/{skuId}
///
/// SKU is the color identifier. The accounting/FIFO identity key is always
/// `productId + sku` (see docs/ARCHITECTURE.md §2) — never the product name.
@freezed
class ProductSku with _$ProductSku {
  const factory ProductSku({
    required String productId,
    required String sku,
    required String colorName,
    String? colorCode,
    required bool isActive,
  }) = _ProductSku;

  factory ProductSku.fromJson(Map<String, dynamic> json) => _$ProductSkuFromJson(json);

  const ProductSku._();

  /// The stable accounting key used everywhere for FIFO / pending lookups.
  /// Format: `{productId}_{sku}` e.g. `PROD001_RED001`.
  String get variantKey => '${productId}_$sku';
}
