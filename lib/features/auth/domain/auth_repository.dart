import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';

/// Contract the presentation layer depends on. The UI/controllers never talk
/// to FirebaseAuth/Firestore directly (§36 — no Firestore in widgets).
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<AppUser?> currentUser();
}
