import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/features/challans/data/firebase_challan_repository.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/domain/challan_repository.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';


final challanRepositoryProvider = Provider<ChallanRepository>((ref) {
  return FirebaseChallanRepository();
});

class ChallanFilter {
  const ChallanFilter({
    this.supplierId,
    this.stitchingUserId,
    this.status,
  });

  final String? supplierId;
  final String? stitchingUserId;
  final ChallanStatus? status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallanFilter &&
          runtimeType == other.runtimeType &&
          supplierId == other.supplierId &&
          stitchingUserId == other.stitchingUserId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(supplierId, stitchingUserId, status);
}

final challansStreamProvider =
    StreamProvider.family<List<Challan>, ChallanFilter>((ref, filter) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchChallans(
    supplierId: filter.supplierId,
    stitchingUserId: filter.stitchingUserId,
    status: filter.status,
  );
});

final challanItemsStreamProvider =
    StreamProvider.family<List<ChallanItem>, String>((ref, challanId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchChallanItems(challanId);
});

final challanStreamProvider =
    StreamProvider.family<Challan, String>((ref, challanId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchChallan(challanId);
});

final pendingStitchingItemsStreamProvider =
    StreamProvider.family<List<ChallanItem>, String?>((ref, stitchingUserId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchPendingStitchingItems(stitchingUserId: stitchingUserId);
});

final pendingSupplierItemsStreamProvider =
    StreamProvider.family<List<ChallanItem>, String?>((ref, supplierId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchPendingSupplierItems(supplierId: supplierId);
});

final supplierTransactionsForChallanProvider =
    StreamProvider.family<List<SupplierMaterialTransaction>, String>(
        (ref, challanId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchSupplierTransactionsForChallan(challanId);
});

final productionTransactionsForChallanProvider =
    StreamProvider.family<List<MaterialTransaction>, String>((ref, challanId) {
  final repo = ref.watch(challanRepositoryProvider);
  return repo.watchProductionTransactionsForChallan(challanId);
});

