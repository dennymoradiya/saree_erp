import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/users/data/user_account_creation_service.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_repository.dart';

/// Firebase-backed implementation of [StitchingUserRepository].
/// Reads stream directly from Firestore and uses pure Dart [UserAccountCreationService]
/// to provision Auth credentials and Firestore documents atomically.
class FirebaseStitchingUserRepository implements StitchingUserRepository {
  FirebaseStitchingUserRepository({
    FirebaseFirestore? firestore,
    UserAccountCreationService? userAccountCreationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _accountCreationService =
            userAccountCreationService ?? UserAccountCreationService();

  final FirebaseFirestore _firestore;
  final UserAccountCreationService _accountCreationService;

  @override
  Stream<List<StitchingUserProfile>> watchStitchingUsers() {
    return _firestore
        .collection(FirestorePaths.stitchingUsers)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StitchingUserProfile.fromJson(
          {'stitchingUserId': doc.id, ...doc.data()},
        );
      }).toList();
    });
  }

  @override
  Future<Result<CreatedAccountInfo>> createStitchingUser({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final info = await _accountCreationService.createUserAccount(
        role: 'stitching_user',
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      return Success(info);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }
}
