import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'challan_item.freezed.dart';
part 'challan_item.g.dart';

/// challan_items/{challanItemId}
///
/// Holds BOTH independent accounting dimensions for one product+SKU line of
/// a challan:
///   A. Supplier material state   (required / supplied / supplierPending)
///   B. Stitching production state (issued / returned / pending)
///
/// These two halves are updated by two different engines
/// (SupplierMaterialLedger and StitchingProductionLedger respectively) and
/// must never be conflated (docs/ARCHITECTURE.md §23, §56).
@freezed
class ChallanItem with _$ChallanItem {
  const factory ChallanItem({
    required String challanItemId,
    required String challanId,
    required String productId,
    required String sku,

    // Snapshots — historical records must never change when the product
    // master is edited later (§49).
    required String productNameSnapshot,
    required String skuSnapshot,
    String? colorNameSnapshot,

    // --- A. Stitching production state (finished saree) ---
    required double sareeIssuedQuantity,
    required double sareeReturnedQuantity,
    required double sareePendingQuantity,

    // --- B. Supplier raw-material state, per component ---
    required double laceRequiredQuantity,
    required double laceSuppliedQuantity,
    required double lacePendingSupplierQuantity,
    required double blouseRequiredQuantity,
    required double blouseSuppliedQuantity,
    required double blousePendingSupplierQuantity,

    // Saree-component supplier state (saree material itself can also be
    // short-delivered even though it is usually 1:1 with the issued qty).
    required double sareeRequiredQuantity,
    required double sareeSuppliedQuantity,
    required double sareePendingSupplierQuantity,

    /// Convenience mirror of sareeReturnedQuantity kept for reporting;
    /// canonical source of truth is sareeReturnedQuantity above.
    @Default(0) double stitchingReturnedQuantity,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _ChallanItem;

  factory ChallanItem.fromJson(Map<String, dynamic> json) =>
      _$ChallanItemFromJson(json);
}
