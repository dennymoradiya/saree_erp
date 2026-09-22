import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';

/// Maps low-level Firebase/Firestore exceptions (including errors thrown by
/// Cloud Functions callable results) into [AppException]s the UI can render.
AppException mapFirebaseError(Object error) {
  Object target = error;
  try {
    final dynamic dyn = error;
    if (dyn != null && dyn.error != null) {
      target = dyn.error;
    }
  } catch (_) {}

  if (target is FirebaseException) {
    switch (target.code) {
      case 'permission-denied':
        return PermissionDeniedException(
          target.message ?? 'Permission denied. Please check your role permissions.',
        );
      case 'not-found':
        return NotFoundException(target.message ?? 'Record not found.');
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkException(
          'Network issue. Please check your connection and try again.',
        );
      case 'already-exists':
        return DuplicateOperationException(
          target.message ?? 'A record with this identifier already exists.',
        );
      case 'failed-precondition':
        return LedgerViolationException(
          target.message ??
              'This action conflicts with the current ledger state.',
        );
      default:
        return UnknownAppException(target.message ?? target.code);
    }
  }

  final msg = target.toString();
  // Strip verbose stack strings if needed
  if (msg.contains('Exception: ')) {
    return UnknownAppException(msg.replaceFirst('Exception: ', ''));
  }
  return UnknownAppException(msg);
}

