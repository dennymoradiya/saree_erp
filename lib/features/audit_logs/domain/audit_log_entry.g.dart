// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogEntryImpl _$$AuditLogEntryImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogEntryImpl(
      logId: json['logId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      actorId: json['actorId'] as String,
      actorRole: json['actorRole'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      beforeData: json['beforeData'] as Map<String, dynamic>?,
      afterData: json['afterData'] as Map<String, dynamic>?,
      reason: json['reason'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AuditLogEntryImplToJson(_$AuditLogEntryImpl instance) =>
    <String, dynamic>{
      'logId': instance.logId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'actorId': instance.actorId,
      'actorRole': instance.actorRole,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'beforeData': instance.beforeData,
      'afterData': instance.afterData,
      'reason': instance.reason,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$AuditActionEnumMap = {
  AuditAction.challanCreated: 'CHALLAN_CREATED',
  AuditAction.challanCancelled: 'CHALLAN_CANCELLED',
  AuditAction.supplierMaterialReceived: 'SUPPLIER_MATERIAL_RECEIVED',
  AuditAction.supplierPendingAllocated: 'SUPPLIER_PENDING_ALLOCATED',
  AuditAction.depositRequestCreated: 'DEPOSIT_REQUEST_CREATED',
  AuditAction.depositRequestApproved: 'DEPOSIT_REQUEST_APPROVED',
  AuditAction.depositRequestRejected: 'DEPOSIT_REQUEST_REJECTED',
  AuditAction.manualReturnRecorded: 'MANUAL_RETURN_RECORDED',
  AuditAction.adjustmentCreated: 'ADJUSTMENT_CREATED',
  AuditAction.adminCreatedUserAccount: 'ADMIN_CREATED_USER_ACCOUNT',
};
