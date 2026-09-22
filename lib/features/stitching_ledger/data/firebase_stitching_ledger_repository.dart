import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/enums/transaction_type.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_repository.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';

class FirebaseStitchingLedgerRepository implements StitchingLedgerRepository {
  FirebaseStitchingLedgerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<MaterialTransaction>> watchReturnTransactions({
    String? stitchingUserId,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(FirestorePaths.materialTransactions);

    if (stitchingUserId != null && stitchingUserId.isNotEmpty) {
      query = query.where('stitchingUserId', isEqualTo: stitchingUserId);
    }

    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) {
            return MaterialTransaction.fromJson({
              'transactionId': doc.id,
              ...doc.data(),
            });
          })
          .where((tx) =>
              tx.type == TransactionType.returnApproved ||
              tx.type == TransactionType.stitchingReturn)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
