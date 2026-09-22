import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/suppliers/data/firebase_supplier_repository.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier_repository.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return FirebaseSupplierRepository();
});

final suppliersListProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(supplierRepositoryProvider).watchSuppliers();
});

class SupplierController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<CreatedAccountInfo?> createSupplier({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(supplierRepositoryProvider);
    final result = await repo.createSupplier(
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
        debugPrint('createSupplier failure: $error');
        state = AsyncError(error, StackTrace.current);
        return null;
      },
    );
  }
}

final supplierControllerProvider =
    AsyncNotifierProvider<SupplierController, void>(SupplierController.new);
