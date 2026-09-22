import 'package:freezed_annotation/freezed_annotation.dart';

/// Lifecycle status of a challan (production side).
///
/// Supplier-side pending material must NEVER be derived from this status.
/// See docs/ARCHITECTURE.md section "Two independent ledgers".
@JsonEnum(valueField: 'value', alwaysCreate: true)
enum ChallanStatus {
  @JsonValue('draft')
  draft('draft'),

  @JsonValue('issued')
  issued('issued'),

  @JsonValue('partially_completed')
  partiallyCompleted('partially_completed'),

  @JsonValue('completed')
  completed('completed'),

  @JsonValue('cancelled')
  cancelled('cancelled');

  const ChallanStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ChallanStatus.draft:
        return 'Draft';
      case ChallanStatus.issued:
        return 'Issued';
      case ChallanStatus.partiallyCompleted:
        return 'Partially Completed';
      case ChallanStatus.completed:
        return 'Completed';
      case ChallanStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ChallanStatus fromValue(dynamic value) {
    if (value == null) return ChallanStatus.draft;
    if (value is ChallanStatus) return value;
    final normalized = value
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    if (normalized == 'partially_completed' ||
        normalized == 'partiallycompleted') {
      return ChallanStatus.partiallyCompleted;
    }

    for (final status in ChallanStatus.values) {
      if (status.value.toLowerCase() == normalized ||
          status.name.toLowerCase() == normalized) {
        return status;
      }
    }
    return ChallanStatus.draft;
  }
}

