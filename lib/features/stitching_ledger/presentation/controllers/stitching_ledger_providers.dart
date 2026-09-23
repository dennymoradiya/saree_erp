import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/stitching_ledger/data/firebase_stitching_ledger_repository.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_models.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_repository.dart';
import 'package:saree_sutra/features/supplier_ledger/presentation/controllers/supplier_ledger_providers.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class StitchingLedgerFilterState {
  const StitchingLedgerFilterState({
    this.stitchingUserId,
    this.dateFilter = LedgerDateFilter.allTime,
    this.customStartDate,
    this.customEndDate,
  });

  final String? stitchingUserId;
  final LedgerDateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  StitchingLedgerFilterState copyWith({
    String? stitchingUserId,
    bool clearUser = false,
    LedgerDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return StitchingLedgerFilterState(
      stitchingUserId:
          clearUser ? null : (stitchingUserId ?? this.stitchingUserId),
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

class StitchingLedgerFilterNotifier
    extends StateNotifier<StitchingLedgerFilterState> {
  StitchingLedgerFilterNotifier({String? initialStitchingUserId})
      : super(StitchingLedgerFilterState(
            stitchingUserId: initialStitchingUserId));

  void setStitchingUser(String? userId) {
    state = state.copyWith(stitchingUserId: userId, clearUser: userId == null);
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

final stitchingLedgerRepositoryProvider =
    Provider<StitchingLedgerRepository>((ref) {
  return FirebaseStitchingLedgerRepository();
});

final stitchingLedgerFilterProvider = StateNotifierProvider.family<
    StitchingLedgerFilterNotifier, StitchingLedgerFilterState, String?>(
  (ref, initialUserId) =>
      StitchingLedgerFilterNotifier(initialStitchingUserId: initialUserId),
);

final rawReturnTransactionsStreamProvider =
    StreamProvider.family<List<MaterialTransaction>, String?>(
        (ref, stitchingUserId) {
  final repo = ref.watch(stitchingLedgerRepositoryProvider);
  return repo.watchReturnTransactions(stitchingUserId: stitchingUserId);
});

/// Computes the day-wise aggregated stitching returns ledger with distribution details and challan backlinks.
final dayWiseStitchingLedgerProvider =
    Provider.family<AsyncValue<List<DayWiseStitchingLedger>>, String?>(
        (ref, initialUserId) {
  final filter = ref.watch(stitchingLedgerFilterProvider(initialUserId));
  final txsAsync =
      ref.watch(rawReturnTransactionsStreamProvider(filter.stitchingUserId));
  final challansAsync =
      ref.watch(challansStreamProvider(const ChallanFilter()));
  final usersAsync = ref.watch(stitchingUsersListProvider);
  final productsAsync = ref.watch(productsStreamProvider);

  if (txsAsync.isLoading || challansAsync.isLoading || usersAsync.isLoading) {
    return const AsyncLoading();
  }

  if (txsAsync.hasError) {
    return AsyncError(txsAsync.error!, txsAsync.stackTrace!);
  }

  final transactions = txsAsync.value ?? [];
  final challans = challansAsync.value ?? [];
  final users = usersAsync.value ?? [];
  final products = productsAsync.value ?? [];

  final challanMap = {for (final c in challans) c.challanId: c.challanNumber};
  final userMap = {for (final u in users) u.stitchingUserId: u.name};
  final productMap = {for (final p in products) p.productId: p.name};

  // 1. Filter by date
  final filteredTxs =
      transactions.where((tx) => filter.matchesDate(tx.createdAt)).toList();

  // 2. Group by date
  final Map<DateTime, List<StitchingDistributionItem>> dayGroups = {};
  final Map<DateTime, double> returnedTotals = {};

  for (final tx in filteredTxs) {
    final dayKey =
        DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);

    final challanNum = challanMap[tx.challanId] ?? tx.challanId;
    final uName = userMap[tx.stitchingUserId] ?? tx.stitchingUserId;
    final prodName = productMap[tx.productId] ?? tx.productId;

    final distItem = StitchingDistributionItem(
      transactionId: tx.transactionId,
      challanId: tx.challanId,
      challanNumber: challanNum,
      stitchingUserId: tx.stitchingUserId,
      stitchingUserName: uName,
      productId: tx.productId,
      productName: prodName,
      sku: tx.sku,
      quantity: tx.quantity,
      timestamp: tx.createdAt,
      depositRequestId: tx.depositRequestId,
      notes: tx.notes,
    );

    dayGroups.putIfAbsent(dayKey, () => []).add(distItem);
    returnedTotals[dayKey] = (returnedTotals[dayKey] ?? 0) + tx.quantity;
  }

  // 3. Build sorted list
  final sortedDays = dayGroups.keys.toList()..sort((a, b) => b.compareTo(a));

  final result = sortedDays.map((day) {
    final dists = dayGroups[day]!
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return DayWiseStitchingLedger(
      date: day,
      totalReturnedQuantity: returnedTotals[day] ?? 0,
      totalEvents: dists.length,
      distributions: dists,
    );
  }).toList();

  return AsyncData(result);
});
