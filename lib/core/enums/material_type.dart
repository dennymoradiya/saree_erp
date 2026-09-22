import 'package:freezed_annotation/freezed_annotation.dart';

/// Raw-material component types tracked independently per challan item.
///
/// FIFO allocation for supplier pending material is always scoped per
/// materialType — never combine SAREE / LACE / BLOUSE into one bucket.
@JsonEnum(valueField: 'value', alwaysCreate: true)
enum MaterialType {
  @JsonValue('SAREE')
  saree('SAREE'),

  @JsonValue('LACE')
  lace('LACE'),

  @JsonValue('BLOUSE')
  blouse('BLOUSE');

  const MaterialType(this.value);
  final String value;

  static MaterialType fromValue(dynamic value) {
    if (value == null) return MaterialType.saree;
    if (value is MaterialType) return value;
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    for (final type in MaterialType.values) {
      if (type.value.toUpperCase() == normalized ||
          type.name.toUpperCase() == normalized) {
        return type;
      }
    }
    return MaterialType.saree;
  }
}

