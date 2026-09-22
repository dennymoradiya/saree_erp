// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaterialTransactionImpl _$$MaterialTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$MaterialTransactionImpl(
      transactionId: json['transactionId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      challanId: json['challanId'] as String,
      challanItemId: json['challanItemId'] as String,
      stitchingUserId: json['stitchingUserId'] as String,
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      depositRequestId: json['depositRequestId'] as String?,
      createdBy: json['createdBy'] as String,
      createdByRole: json['createdByRole'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MaterialTransactionImplToJson(
        _$MaterialTransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'challanId': instance.challanId,
      'challanItemId': instance.challanItemId,
      'stitchingUserId': instance.stitchingUserId,
      'productId': instance.productId,
      'sku': instance.sku,
      'quantity': instance.quantity,
      'depositRequestId': instance.depositRequestId,
      'createdBy': instance.createdBy,
      'createdByRole': instance.createdByRole,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notes': instance.notes,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.supplierDelivery: 'SUPPLIER_DELIVERY',
  TransactionType.supplierPendingAllocation: 'SUPPLIER_PENDING_ALLOCATION',
  TransactionType.stitchingIssue: 'STITCHING_ISSUE',
  TransactionType.stitchingReturn: 'STITCHING_RETURN',
  TransactionType.returnRequest: 'RETURN_REQUEST',
  TransactionType.returnApproved: 'RETURN_APPROVED',
  TransactionType.returnRejected: 'RETURN_REJECTED',
  TransactionType.adjustment: 'ADJUSTMENT',
  TransactionType.reversal: 'REVERSAL',
};
