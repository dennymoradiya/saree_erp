import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';

/// Contract for supplier profile retrieval and account creation.
/// The UI/controllers never talk to Firestore or Cloud Functions directly.
abstract interface class SupplierRepository {
  Stream<List<Supplier>> watchSuppliers();

  Future<Result<CreatedAccountInfo>> createSupplier({
    required String name,
    required String email,
    String? phone,
    String? address,
  });
}
