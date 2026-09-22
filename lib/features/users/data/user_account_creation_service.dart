import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/password_generator.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';

/// Pure Dart service to create user accounts directly from the client.
/// Uses a temporary secondary [FirebaseApp] to create new Auth credentials
/// without terminating or replacing the current Admin user's session.
class UserAccountCreationService {
  UserAccountCreationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<CreatedAccountInfo> createUserAccount({
    required String role, // 'supplier' | 'stitching_user'
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    final callerUser = _auth.currentUser;
    if (callerUser == null) {
      throw const PermissionDeniedException('Sign in required.');
    }

    final callerUid = callerUser.uid;

    // Verify caller is active admin
    final callerSnap = await _firestore
        .collection(FirestorePaths.users)
        .doc(callerUid)
        .get();

    if (!callerSnap.exists) {
      throw const PermissionDeniedException('Caller user record not found.');
    }

    final callerData = callerSnap.data();
    if (callerData?['role'] != 'admin' || callerData?['isActive'] != true) {
      throw const PermissionDeniedException(
        'Only active admins can create supplier or stitching user accounts.',
      );
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const UnknownAppException('Name is required.');
    }

    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw const UnknownAppException('A valid email is required.');
    }

    final cleanPhone = (phone != null && phone.trim().isNotEmpty)
        ? phone.trim()
        : null;
    final cleanAddress = (address != null && address.trim().isNotEmpty)
        ? address.trim()
        : null;

    final temporaryPassword =
        PasswordGenerator.generateTemporaryPassword(length: 12);

    // Initialize temporary secondary app for isolated user creation
    final secondaryAppName =
        'SecondaryAuthApp_${DateTime.now().microsecondsSinceEpoch}';
    final secondaryApp = await Firebase.initializeApp(
      name: secondaryAppName,
      options: Firebase.app().options,
    );

    UserCredential? newUserCred;
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      try {
        newUserCred = await secondaryAuth.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: temporaryPassword,
        );
      } on FirebaseAuthException catch (authErr) {
        if (authErr.code == 'email-already-in-use') {
          throw const DuplicateOperationException(
            'An account with this email already exists.',
          );
        }
        throw mapFirebaseError(authErr);
      }

      final newUid = newUserCred.user!.uid;
      await newUserCred.user?.updateDisplayName(trimmedName);

      String? createdProfileId;

      await _firestore.runTransaction((tx) async {
        final now = FieldValue.serverTimestamp();

        if (role == 'supplier') {
          final supplierRef =
              _firestore.collection(FirestorePaths.suppliers).doc();
          createdProfileId = supplierRef.id;

          tx.set(supplierRef, {
            'supplierId': createdProfileId,
            'name': trimmedName,
            'phone': cleanPhone,
            'address': cleanAddress,
            'isActive': true,
            'createdAt': now,
            'updatedAt': now,
            'linkedUserId': newUid,
          });

          final userRef =
              _firestore.collection(FirestorePaths.users).doc(newUid);
          tx.set(userRef, {
            'uid': newUid,
            'name': trimmedName,
            'email': trimmedEmail,
            'role': 'supplier',
            'isActive': true,
            'phone': cleanPhone,
            'supplierId': createdProfileId,
            'stitchingUserId': null,
            'fcmToken': null,
            'createdAt': now,
            'updatedAt': now,
          });
        } else {
          final stitchingUserRef =
              _firestore.collection(FirestorePaths.stitchingUsers).doc();
          createdProfileId = stitchingUserRef.id;

          tx.set(stitchingUserRef, {
            'stitchingUserId': createdProfileId,
            'name': trimmedName,
            'phone': cleanPhone,
            'address': cleanAddress,
            'isActive': true,
            'createdAt': now,
            'updatedAt': now,
            'linkedUserId': newUid,
          });

          final userRef =
              _firestore.collection(FirestorePaths.users).doc(newUid);
          tx.set(userRef, {
            'uid': newUid,
            'name': trimmedName,
            'email': trimmedEmail,
            'role': 'stitching_user',
            'isActive': true,
            'phone': cleanPhone,
            'supplierId': null,
            'stitchingUserId': createdProfileId,
            'fcmToken': null,
            'createdAt': now,
            'updatedAt': now,
          });
        }

        final auditRef =
            _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': 'ADMIN_CREATED_USER_ACCOUNT',
          'actorId': callerUid,
          'actorRole': 'admin',
          'entityType': role,
          'entityId': newUid,
          'beforeData': null,
          'afterData': {
            'email': trimmedEmail,
            'role': role,
            'name': trimmedName,
          },
          'createdAt': now,
        });
      });

      return CreatedAccountInfo(
        uid: newUid,
        email: trimmedEmail,
        temporaryPassword: temporaryPassword,
        supplierId: role == 'supplier' ? createdProfileId : null,
        stitchingUserId: role == 'stitching_user' ? createdProfileId : null,
      );
    } catch (e) {
      // Rollback: if Auth user was created but transaction failed, delete the orphaned Auth user
      if (newUserCred?.user != null) {
        try {
          await newUserCred!.user!.delete();
        } catch (_) {}
      }

      if (e is AppException) {
        rethrow;
      }
      throw mapFirebaseError(e);
    } finally {
      await secondaryApp.delete();
    }
  }
}
