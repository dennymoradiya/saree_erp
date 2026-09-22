import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';

/// Contract for stitching user profile retrieval and account creation.
/// The UI/controllers never talk to Firestore or Cloud Functions directly.
abstract interface class StitchingUserRepository {
  Stream<List<StitchingUserProfile>> watchStitchingUsers();

  Future<Result<CreatedAccountInfo>> createStitchingUser({
    required String name,
    required String email,
    String? phone,
    String? address,
  });
}
