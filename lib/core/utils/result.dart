import 'package:saree_sutra/core/errors/app_exception.dart';

/// A minimal Result type so repositories never throw across layers silently.
/// Controllers/notifiers pattern-match on this instead of try/catch spaghetti.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failure<T>) return failure(self.error);
    throw StateError('Unreachable');
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
