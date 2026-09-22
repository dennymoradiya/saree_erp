import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/users/data/firebase_stitching_user_repository.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_repository.dart';

final stitchingUserRepositoryProvider =
    Provider<StitchingUserRepository>((ref) {
  return FirebaseStitchingUserRepository();
});

final stitchingUsersListProvider =
    StreamProvider<List<StitchingUserProfile>>((ref) {
  return ref.watch(stitchingUserRepositoryProvider).watchStitchingUsers();
});

class StitchingUserController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<CreatedAccountInfo?> createStitchingUser({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(stitchingUserRepositoryProvider);
    final result = await repo.createStitchingUser(
      name: name,
      email: email,
      phone: phone,
      address: address,
    );
    return result.when(
      success: (info) {
        state = const AsyncData(null);
        return info;
      },
      failure: (error) {
        debugPrint('createStitchingUser failure: $error');
        state = AsyncError(error, StackTrace.current);
        return null;
      },
    );
  }
}

final stitchingUserControllerProvider =
    AsyncNotifierProvider<StitchingUserController, void>(
  StitchingUserController.new,
);
