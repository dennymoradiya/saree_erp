import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/auth/data/firebase_auth_repository.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';
import 'package:saree_sutra/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// The single source of truth for "who is logged in right now". go_router's
/// redirect logic listens to this via [authStateNotifierProvider] below.
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Controller for the login screen's imperative actions (sign in / sign out /
/// password reset). UI state (loading/error) is exposed via [AsyncValue].
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signIn(email: email, password: password);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (error) {
        state = AsyncError(error, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
