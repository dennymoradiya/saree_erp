import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';
import 'package:saree_sutra/features/auth/domain/auth_repository.dart';

/// Firebase-backed implementation of [AuthRepository].
///
/// The Firebase Auth uid is used as the `users/{uid}` document id. Role is
/// read from Firestore (server-trusted, protected by Security Rules) — never
/// inferred from custom claims on the client alone without also checking
/// Firestore, so an admin can deactivate a user immediately.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  Future<AppUser?> _loadProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromJson({...snap.data()!, 'uid': uid});
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fbUser) {
      if (fbUser == null) return Future.value(null);
      return _loadProfile(fbUser.uid);
    });
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const Failure(
          UnknownAppException('Sign-in failed unexpectedly.'),
        );
      }
      final profile = await _loadProfile(uid);
      if (profile == null) {
        await _auth.signOut();
        return const Failure(
          PermissionDeniedException(
            'No profile found for this account. Contact the administrator.',
          ),
        );
      }
      if (!profile.isActive) {
        await _auth.signOut();
        return const Failure(
          PermissionDeniedException('This account has been deactivated.'),
        );
      }
      return Success(profile);
    } on fb.FirebaseAuthException catch (e) {
      return Failure(_mapAuthError(e));
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return Failure(_mapAuthError(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser?> currentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _loadProfile(uid);
  }

  AppException _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const PermissionDeniedException('Invalid email or password.');
      case 'user-disabled':
        return const PermissionDeniedException(
          'This account has been disabled.',
        );
      case 'too-many-requests':
        return const NetworkException(
          'Too many attempts. Please try again later.',
        );
      default:
        return UnknownAppException(e.message ?? e.code);
    }
  }
}
