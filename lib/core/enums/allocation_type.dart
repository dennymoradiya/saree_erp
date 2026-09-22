import 'package:freezed_annotation/freezed_annotation.dart';

/// How a unit of a supplier delivery was allocated by the FIFO engine.
@JsonEnum(valueField: 'value', alwaysCreate: true)
enum AllocationType {
  @JsonValue('NEW_CHALLAN')
  newChallan('NEW_CHALLAN'),

  @JsonValue('OLD_PENDING_CHALLAN')
  oldPendingChallan('OLD_PENDING_CHALLAN');

  const AllocationType(this.value);
  final String value;

  static AllocationType fromValue(dynamic value) {
    if (value == null) return AllocationType.newChallan;
    if (value is AllocationType) return value;
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    if (normalized == 'NEW_CHALLAN' || normalized == 'NEWCHALLAN') {
      return AllocationType.newChallan;
    }
    if (normalized == 'OLD_PENDING_CHALLAN' ||
        normalized == 'OLDPENDINGCHALLAN') {
      return AllocationType.oldPendingChallan;
    }

    for (final type in AllocationType.values) {
      if (type.value.toUpperCase() == normalized ||
          type.name.toUpperCase() == normalized) {
        return type;
      }
    }
    return AllocationType.newChallan;
  }
}

