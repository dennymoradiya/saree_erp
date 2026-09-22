import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

abstract interface class SupplierLedgerRepository {
  Stream<List<SupplierMaterialTransaction>> watchSupplierTransactions({
    String? supplierId,
  });
}
