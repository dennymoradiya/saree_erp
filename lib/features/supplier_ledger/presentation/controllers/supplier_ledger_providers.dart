import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/supplier_ledger/data/firebase_supplier_ledger_repository.dart';
import 'package:saree_sutra/features/supplier_ledger/domain/supplier_ledger_models.dart';
import 'package:saree_sutra/features/supplier_ledger/domain/supplier_ledger_repository.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

enum LedgerDateFilter {
  allTime('All Time'),
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  thisMonth('This Month'),
  custom('Custom Range');

  const LedgerDateFilter(this.displayName);
  final String displayName;

  /// Returns available date filter options based on whether the user is an admin.
  /// 'All Time' is only available for admin users.
  static List<LedgerDateFilter> availableFilters({required bool isAdmin}) {
    if (isAdmin) {
      return LedgerDateFilter.values;
    }
    return LedgerDateFilter.values
        .where((preset) => preset != LedgerDateFilter.allTime)
        .toList();
  }
}

class SupplierLedgerFilterState {
  const SupplierLedgerFilterState({
    this.supplierId,
    this.dateFilter = LedgerDateFilter.allTime,
    this.customStartDate,
    this.customEndDate,
  });

  final String? supplierId;
  final LedgerDateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  SupplierLedgerFilterState copyWith({
    String? supplierId,
    bool clearSupplier = false,
    LedgerDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return SupplierLedgerFilterState(
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }

  bool matchesDate(DateTime dt) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (dateFilter) {
      case LedgerDateFilter.allTime:
        return true;
      case LedgerDateFilter.today:
        return dt.isAfter(
                todayStart.subtract(const Duration(milliseconds: 1))) &&
            dt.isBefore(todayEnd);
      case LedgerDateFilter.yesterday:
        final yStart = todayStart.subtract(const Duration(days: 1));
        final yEnd =
            DateTime(yStart.year, yStart.month, yStart.day, 23, 59, 59, 999);
        return dt.isAfter(yStart.subtract(const Duration(milliseconds: 1))) &&
            dt.isBefore(yEnd);
      case LedgerDateFilter.last7Days:
        final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
        return dt.isAfter(
                sevenDaysAgo.subtract(const Duration(milliseconds: 1))) &&
            dt.isBefore(todayEnd);
      case LedgerDateFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return dt.isAfter(
                monthStart.subtract(const Duration(milliseconds: 1))) &&
            dt.isBefore(todayEnd);
      case LedgerDateFilter.custom:
        if (customStartDate != null) {
          final s = DateTime(customStartDate!.year, customStartDate!.month,
              customStartDate!.day);
          if (dt.isBefore(s)) return false;
        }
        if (customEndDate != null) {
          final e = DateTime(customEndDate!.year, customEndDate!.month,
              customEndDate!.day, 23, 59, 59, 999);
          if (dt.isAfter(e)) return false;
        }
        return true;
    }
  }
}

class SupplierLedgerFilterNotifier
    extends StateNotifier<SupplierLedgerFilterState> {
  SupplierLedgerFilterNotifier({String? initialSupplierId})
      : super(SupplierLedgerFilterState(supplierId: initialSupplierId));

  void setSupplier(String? supplierId) {
    state = state.copyWith(
        supplierId: supplierId, clearSupplier: supplierId == null);
  }

  void setDateFilter(LedgerDateFilter filter,
      {DateTime? customStart, DateTime? customEnd}) {
    state = state.copyWith(
      dateFilter: filter,
      customStartDate: customStart,
      customEndDate: customEnd,
    );
  }
}

final supplierLedgerRepositoryProvider =
    Provider<SupplierLedgerRepository>((ref) {
  return FirebaseSupplierLedgerRepository();
});

final supplierLedgerFilterProvider = StateNotifierProvider.family<
    SupplierLedgerFilterNotifier, SupplierLedgerFilterState, String?>(
  (ref, initialSupplierId) =>
      SupplierLedgerFilterNotifier(initialSupplierId: initialSupplierId),
);

final rawSupplierTransactionsStreamProvider =
    StreamProvider.family<List<SupplierMaterialTransaction>, String?>(
        (ref, supplierId) {
  final repo = ref.watch(supplierLedgerRepositoryProvider);
  return repo.watchSupplierTransactions(supplierId: supplierId);
});

/// Computes the day-wise aggregated supplier ledger with distribution details and challan backlinks.
final dayWiseSupplierLedgerProvider =
    Provider.family<AsyncValue<List<DayWiseSupplierLedger>>, String?>(
        (ref, initialSupplierId) {
  final filter = ref.watch(supplierLedgerFilterProvider(initialSupplierId));
  final txsAsync =
      ref.watch(rawSupplierTransactionsStreamProvider(filter.supplierId));
  final challansAsync =
      ref.watch(challansStreamProvider(const ChallanFilter()));
  final suppliersAsync = ref.watch(suppliersListProvider);
  final productsAsync = ref.watch(productsStreamProvider);

  if (txsAsync.isLoading ||
      challansAsync.isLoading ||
      suppliersAsync.isLoading) {
    return const AsyncLoading();
  }

  if (txsAsync.hasError) {
    return AsyncError(txsAsync.error!, txsAsync.stackTrace!);
  }

  final transactions = txsAsync.value ?? [];
  final challans = challansAsync.value ?? [];
  final suppliers = suppliersAsync.value ?? [];
  final products = productsAsync.value ?? [];

  final challanMap = {for (final c in challans) c.challanId: c.challanNumber};
  final supplierMap = {for (final s in suppliers) s.supplierId: s.name};
  final productMap = {for (final p in products) p.productId: p.name};

  // 1. Filter by date
  final filteredTxs =
      transactions.where((tx) => filter.matchesDate(tx.createdAt)).toList();

  // 2. Group by date (normalized to midnight)
  final Map<DateTime, List<SupplierDistributionItem>> dayGroups = {};
  final Map<DateTime, double> sareeTotals = {};
  final Map<DateTime, double> laceTotals = {};
  final Map<DateTime, double> blouseTotals = {};

  for (final tx in filteredTxs) {
    final dayKey =
        DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);

    final challanNum = challanMap[tx.challanId] ?? tx.challanId;
    final supName = supplierMap[tx.supplierId] ?? tx.supplierId;
    final prodName = productMap[tx.productId] ?? tx.productId;

    final distItem = SupplierDistributionItem(
      transactionId: tx.transactionId,
      deliveryBatchId: tx.deliveryBatchId,
      challanId: tx.challanId,
      challanNumber: challanNum,
      supplierId: tx.supplierId,
      supplierName: supName,
      productId: tx.productId,
      productName: prodName,
      sku: tx.sku,
      materialType: tx.materialType,
      quantity: tx.quantity,
      allocationType: tx.allocationType,
      timestamp: tx.createdAt,
      notes: tx.notes,
    );

    dayGroups.putIfAbsent(dayKey, () => []).add(distItem);

    if (tx.materialType == MaterialType.saree) {
      sareeTotals[dayKey] = (sareeTotals[dayKey] ?? 0) + tx.quantity;
    } else if (tx.materialType == MaterialType.lace) {
      laceTotals[dayKey] = (laceTotals[dayKey] ?? 0) + tx.quantity;
    } else if (tx.materialType == MaterialType.blouse) {
      blouseTotals[dayKey] = (blouseTotals[dayKey] ?? 0) + tx.quantity;
    }
  }

  // 3. Build sorted list of DayWiseSupplierLedger
  final sortedDays = dayGroups.keys.toList()..sort((a, b) => b.compareTo(a));

  final result = sortedDays.map((day) {
    final dists = dayGroups[day]!
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return DayWiseSupplierLedger(
      date: day,
      totalSaree: sareeTotals[day] ?? 0,
      totalLace: laceTotals[day] ?? 0,
      totalBlouse: blouseTotals[day] ?? 0,
      totalTransactions: dists.length,
      distributions: dists,
    );
  }).toList();

  return AsyncData(result);
});
