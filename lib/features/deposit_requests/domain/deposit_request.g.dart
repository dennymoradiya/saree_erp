// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DepositRequestItemImpl _$$DepositRequestItemImplFromJson(
        Map<String, dynamic> json) =>
    _$DepositRequestItemImpl(
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      requestedQuantity: (json['requestedQuantity'] as num).toDouble(),
    );

Map<String, dynamic> _$$DepositRequestItemImplToJson(
        _$DepositRequestItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'sku': instance.sku,
      'requestedQuantity': instance.requestedQuantity,
    };

_$DepositRequestImpl _$$DepositRequestImplFromJson(Map<String, dynamic> json) =>
    _$DepositRequestImpl(
      requestId: json['requestId'] as String,
      stitchingUserId: json['stitchingUserId'] as String,
      status: $enumDecode(_$DepositRequestStatusEnumMap, json['status']),
      items: (json['items'] as List<dynamic>)
          .map((e) => DepositRequestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
      reviewedAt:
          const NullableTimestampConverter().fromJson(json['reviewedAt']),
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      resultingTransactionIds:
          (json['resultingTransactionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$$DepositRequestImplToJson(
        _$DepositRequestImpl instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'stitchingUserId': instance.stitchingUserId,
      'status': _$DepositRequestStatusEnumMap[instance.status]!,
      'items': instance.items,
      'notes': instance.notes,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
      'reviewedAt':
          const NullableTimestampConverter().toJson(instance.reviewedAt),
      'reviewedBy': instance.reviewedBy,
      'rejectionReason': instance.rejectionReason,
      'resultingTransactionIds': instance.resultingTransactionIds,
    };

const _$DepositRequestStatusEnumMap = {
  DepositRequestStatus.pending: 'PENDING',
  DepositRequestStatus.approved: 'APPROVED',
  DepositRequestStatus.rejected: 'REJECTED',
  DepositRequestStatus.cancelled: 'CANCELLED',
};
