import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/features/supplier_ledger/domain/supplier_ledger_repository.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

class FirebaseSupplierLedgerRepository implements SupplierLedgerRepository {
  FirebaseSupplierLedgerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<SupplierMaterialTransaction>> watchSupplierTransactions({
    String? supplierId,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(FirestorePaths.supplierMaterialTransactions);

    if (supplierId != null && supplierId.isNotEmpty) {
      query = query.where('supplierId', isEqualTo: supplierId);
    }

    return query.snapshots().map((snap) {
      final list = snap.docs.map((doc) {
        return SupplierMaterialTransaction.fromJson({
          'transactionId': doc.id,
          ...doc.data(),
        });
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
