import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier_repository.dart';
import 'package:saree_sutra/features/users/data/user_account_creation_service.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';

/// Firebase-backed implementation of [SupplierRepository].
/// Reads stream directly from Firestore and uses pure Dart [UserAccountCreationService]
/// to provision Auth credentials and Firestore documents atomically.
class FirebaseSupplierRepository implements SupplierRepository {
  FirebaseSupplierRepository({
    FirebaseFirestore? firestore,
    UserAccountCreationService? userAccountCreationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _accountCreationService =
            userAccountCreationService ?? UserAccountCreationService();

  final FirebaseFirestore _firestore;
  final UserAccountCreationService _accountCreationService;

  @override
  Stream<List<Supplier>> watchSuppliers() {
    return _firestore
        .collection(FirestorePaths.suppliers)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Supplier.fromJson({'supplierId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Future<Result<CreatedAccountInfo>> createSupplier({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final info = await _accountCreationService.createUserAccount(
        role: 'supplier',
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      return Success(info);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }
}
