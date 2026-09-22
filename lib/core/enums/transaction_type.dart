import 'package:freezed_annotation/freezed_annotation.dart';

/// Immutable ledger transaction types. Every important material or
/// production movement MUST create one of these — never rely on mutable
/// counters alone. See docs/ARCHITECTURE.md section 34.
@JsonEnum(valueField: 'value', alwaysCreate: true)
enum TransactionType {
  @JsonValue('SUPPLIER_DELIVERY')
  supplierDelivery('SUPPLIER_DELIVERY'),

  @JsonValue('SUPPLIER_PENDING_ALLOCATION')
  supplierPendingAllocation('SUPPLIER_PENDING_ALLOCATION'),

  @JsonValue('STITCHING_ISSUE')
  stitchingIssue('STITCHING_ISSUE'),

  @JsonValue('STITCHING_RETURN')
  stitchingReturn('STITCHING_RETURN'),

  @JsonValue('RETURN_REQUEST')
  returnRequest('RETURN_REQUEST'),

  @JsonValue('RETURN_APPROVED')
  returnApproved('RETURN_APPROVED'),

  @JsonValue('RETURN_REJECTED')
  returnRejected('RETURN_REJECTED'),

  @JsonValue('ADJUSTMENT')
  adjustment('ADJUSTMENT'),

  @JsonValue('REVERSAL')
  reversal('REVERSAL');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromValue(dynamic value) {
    if (value == null) return TransactionType.adjustment;
    if (value is TransactionType) return value;
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    for (final type in TransactionType.values) {
      if (type.value.toUpperCase() == normalized ||
          type.name.toUpperCase() == normalized) {
        return type;
      }
    }
    return TransactionType.adjustment;
  }
}

