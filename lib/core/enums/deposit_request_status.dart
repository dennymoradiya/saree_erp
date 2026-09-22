import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value', alwaysCreate: true)
enum DepositRequestStatus {
  @JsonValue('PENDING')
  pending('PENDING'),

  @JsonValue('APPROVED')
  approved('APPROVED'),

  @JsonValue('REJECTED')
  rejected('REJECTED'),

  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const DepositRequestStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case DepositRequestStatus.pending:
        return 'Pending';
      case DepositRequestStatus.approved:
        return 'Approved';
      case DepositRequestStatus.rejected:
        return 'Rejected';
      case DepositRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  static DepositRequestStatus fromValue(dynamic value) {
    if (value == null) return DepositRequestStatus.pending;
    if (value is DepositRequestStatus) return value;
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    for (final status in DepositRequestStatus.values) {
      if (status.value.toUpperCase() == normalized ||
          status.name.toUpperCase() == normalized) {
        return status;
      }
    }
    return DepositRequestStatus.pending;
  }
}

