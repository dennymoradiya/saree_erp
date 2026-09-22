import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'stitching_user_profile.freezed.dart';
part 'stitching_user_profile.g.dart';

/// stitching_users/{stitchingUserId} — business profile, separate from the
/// `users/{uid}` auth account.
@freezed
class StitchingUserProfile with _$StitchingUserProfile {
  const factory StitchingUserProfile({
    required String stitchingUserId,
    required String name,
    String? linkedUserId,
    String? phone,
    String? address,
    required bool isActive,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _StitchingUserProfile;

  factory StitchingUserProfile.fromJson(Map<String, dynamic> json) =>
      _$StitchingUserProfileFromJson(json);
}
