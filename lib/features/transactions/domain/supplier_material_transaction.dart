import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'supplier_material_transaction.freezed.dart';
part 'supplier_material_transaction.g.dart';

MaterialType _materialTypeFromJson(dynamic val) => MaterialType.fromValue(val);
String _materialTypeToJson(MaterialType type) => type.value;

AllocationType _allocationTypeFromJson(dynamic val) => AllocationType.fromValue(val);
String _allocationTypeToJson(AllocationType type) => type.value;

/// supplier_material_transactions/{transactionId}
///
/// One row per (delivery split) allocation. A single physical delivery of,
/// say, 15 lace pieces can produce TWO rows: one OLD_PENDING_CHALLAN
/// allocation and one NEW_CHALLAN allocation, both pointing at the same
/// source delivery via [deliveryBatchId] (§24, §31).
@freezed
class SupplierMaterialTransaction with _$SupplierMaterialTransaction {
  const factory SupplierMaterialTransaction({
    required String transactionId,

    /// Groups all allocation rows produced by one physical delivery event.
    required String deliveryBatchId,
    required String supplierId,
    required String productId,
    required String sku,
    @JsonKey(fromJson: _materialTypeFromJson, toJson: _materialTypeToJson)
    required MaterialType materialType,
    required double quantity,
    required String challanId,
    required String challanItemId,
    @JsonKey(fromJson: _allocationTypeFromJson, toJson: _allocationTypeToJson)
    required AllocationType allocationType,

    /// When allocationType == oldPendingChallan, this is the id of the
    /// original challan item whose supplier-pending balance was reduced.
    String? allocationReferenceId,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    String? notes,
  }) = _SupplierMaterialTransaction;

  factory SupplierMaterialTransaction.fromJson(Map<String, dynamic> json) =>
      _$SupplierMaterialTransactionFromJson(json);
}
