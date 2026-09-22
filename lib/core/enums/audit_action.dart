import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value', alwaysCreate: true)
enum AuditAction {
  @JsonValue('CHALLAN_CREATED')
  challanCreated('CHALLAN_CREATED'),

  @JsonValue('CHALLAN_CANCELLED')
  challanCancelled('CHALLAN_CANCELLED'),

  @JsonValue('SUPPLIER_MATERIAL_RECEIVED')
  supplierMaterialReceived('SUPPLIER_MATERIAL_RECEIVED'),

  @JsonValue('SUPPLIER_PENDING_ALLOCATED')
  supplierPendingAllocated('SUPPLIER_PENDING_ALLOCATED'),

  @JsonValue('DEPOSIT_REQUEST_CREATED')
  depositRequestCreated('DEPOSIT_REQUEST_CREATED'),

  @JsonValue('DEPOSIT_REQUEST_APPROVED')
  depositRequestApproved('DEPOSIT_REQUEST_APPROVED'),

  @JsonValue('DEPOSIT_REQUEST_REJECTED')
  depositRequestRejected('DEPOSIT_REQUEST_REJECTED'),

  @JsonValue('MANUAL_RETURN_RECORDED')
  manualReturnRecorded('MANUAL_RETURN_RECORDED'),

  @JsonValue('ADJUSTMENT_CREATED')
  adjustmentCreated('ADJUSTMENT_CREATED'),

  @JsonValue('ADMIN_CREATED_USER_ACCOUNT')
  adminCreatedUserAccount('ADMIN_CREATED_USER_ACCOUNT');

  const AuditAction(this.value);
  final String value;

  static AuditAction fromValue(dynamic value) {
    if (value == null) return AuditAction.adjustmentCreated;
    if (value is AuditAction) return value;
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    for (final action in AuditAction.values) {
      if (action.value.toUpperCase() == normalized ||
          action.name.toUpperCase() == normalized) {
        return action;
      }
    }
    return AuditAction.adjustmentCreated;
  }
}

