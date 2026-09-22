import 'package:freezed_annotation/freezed_annotation.dart';

part 'created_account_info.freezed.dart';
part 'created_account_info.g.dart';

/// Returned by the createSupplierOrStitchingUser Cloud Function.
/// Contains the newly generated Auth UID and temporary password.
@freezed
class CreatedAccountInfo with _$CreatedAccountInfo {
  const factory CreatedAccountInfo({
    required String uid,
    required String email,
    required String temporaryPassword,
    String? supplierId,
    String? stitchingUserId,
  }) = _CreatedAccountInfo;

  factory CreatedAccountInfo.fromJson(Map<String, dynamic> json) =>
      _$CreatedAccountInfoFromJson(json);
}
