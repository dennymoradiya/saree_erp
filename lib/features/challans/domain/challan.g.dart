// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallanImpl _$$ChallanImplFromJson(Map<String, dynamic> json) =>
    _$ChallanImpl(
      challanId: json['challanId'] as String,
      challanNumber: json['challanNumber'] as String,
      supplierId: json['supplierId'] as String,
      stitchingUserId: json['stitchingUserId'] as String,
      createdBy: json['createdBy'] as String,
      createdByRole: json['createdByRole'] as String,
      status: _statusFromJson(json['status']),
      issuedAt: const TimestampConverter().fromJson(json['issuedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      notes: json['notes'] as String?,
      cancelledReason: json['cancelledReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt:
          const NullableTimestampConverter().fromJson(json['cancelledAt']),
    );

Map<String, dynamic> _$$ChallanImplToJson(_$ChallanImpl instance) =>
    <String, dynamic>{
      'challanId': instance.challanId,
      'challanNumber': instance.challanNumber,
      'supplierId': instance.supplierId,
      'stitchingUserId': instance.stitchingUserId,
      'createdBy': instance.createdBy,
      'createdByRole': instance.createdByRole,
      'status': _statusToJson(instance.status),
      'issuedAt': const TimestampConverter().toJson(instance.issuedAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'notes': instance.notes,
      'cancelledReason': instance.cancelledReason,
      'cancelledBy': instance.cancelledBy,
      'cancelledAt':
          const NullableTimestampConverter().toJson(instance.cancelledAt),
    };
