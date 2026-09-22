import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

UserRole _roleFromJson(dynamic val) => UserRole.fromValue(val);
String _roleToJson(UserRole role) => role.value;

/// users/{uid}
///
/// Role is authoritative here (server-trusted). Never infer role from
/// client-side navigation state.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String name,
    required String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
    required UserRole role,

    required bool isActive,
    String? phone,
    // Set only when role == supplier; links to suppliers/{supplierId}.
    String? supplierId,
    // Set only when role == stitchingUser; links to stitching_users/{id}.
    String? stitchingUserId,
    String? fcmToken,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
