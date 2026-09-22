/// Base type for all known, user-facing application errors.
///
/// Repositories/controllers should catch low-level exceptions (FirebaseException,
/// FormatException, etc.) and rethrow as one of these so the UI layer can render
/// a consistent message without knowing about Firebase internals.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when the server rejects an accounting mutation because it would
/// violate an invariant (e.g. negative pending, excess return).
class LedgerViolationException extends AppException {
  const LedgerViolationException(super.message);
}

/// Thrown when a duplicate/blocking condition is detected, e.g. an existing
/// PENDING deposit request the admin must review before a manual return.
class DuplicateOperationException extends AppException {
  const DuplicateOperationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnknownAppException extends AppException {
  const UnknownAppException(super.message);
}
