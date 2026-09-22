import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';

abstract interface class StitchingLedgerRepository {
  Stream<List<MaterialTransaction>> watchReturnTransactions({
    String? stitchingUserId,
  });
}
