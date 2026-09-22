import 'package:freezed_annotation/freezed_annotation.dart';

/// The three business roles in the system.
///
/// IMPORTANT: The string values are persisted in Firestore (`users/{uid}.role`)
/// and are also relied upon by Firestore Security Rules and Cloud Functions.
/// Do not rename these values without a data-migration plan.
@JsonEnum(valueField: 'value', alwaysCreate: true)
enum UserRole {
  @JsonValue('admin')
  admin('admin'),

  @JsonValue('stitching_user')
  stitchingUser('stitching_user'),

  @JsonValue('supplier')
  supplier('supplier');

  const UserRole(this.value);
  final String value;

  static UserRole fromValue(dynamic value) {
    if (value == null) return UserRole.admin;
    if (value is UserRole) return value;
    final normalized = value
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    if (normalized == 'stitching_user' ||
        normalized == 'stitchinguser' ||
        normalized == 'stitching') {
      return UserRole.stitchingUser;
    }
    if (normalized == 'supplier') {
      return UserRole.supplier;
    }
    if (normalized == 'admin') {
      return UserRole.admin;
    }

    for (final role in UserRole.values) {
      if (role.value.toLowerCase() == normalized ||
          role.name.toLowerCase() == normalized) {
        return role;
      }
    }
    return UserRole.admin;
  }
}

