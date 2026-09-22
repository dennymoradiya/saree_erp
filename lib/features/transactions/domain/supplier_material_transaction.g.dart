// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_material_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupplierMaterialTransactionImpl _$$SupplierMaterialTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$SupplierMaterialTransactionImpl(
      transactionId: json['transactionId'] as String,
      deliveryBatchId: json['deliveryBatchId'] as String,
      supplierId: json['supplierId'] as String,
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      materialType: _materialTypeFromJson(json['materialType']),
      quantity: (json['quantity'] as num).toDouble(),
      challanId: json['challanId'] as String,
      challanItemId: json['challanItemId'] as String,
      allocationType: _allocationTypeFromJson(json['allocationType']),
      allocationReferenceId: json['allocationReferenceId'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$SupplierMaterialTransactionImplToJson(
        _$SupplierMaterialTransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'deliveryBatchId': instance.deliveryBatchId,
      'supplierId': instance.supplierId,
      'productId': instance.productId,
      'sku': instance.sku,
      'materialType': _materialTypeToJson(instance.materialType),
      'quantity': instance.quantity,
      'challanId': instance.challanId,
      'challanItemId': instance.challanItemId,
      'allocationType': _allocationTypeToJson(instance.allocationType),
      'allocationReferenceId': instance.allocationReferenceId,
      'createdBy': instance.createdBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notes': instance.notes,
    };
