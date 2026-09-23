import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_models.dart';
import 'package:saree_sutra/features/supplier_ledger/domain/supplier_ledger_models.dart';
import 'package:saree_sutra/features/supplier_ledger/presentation/controllers/supplier_ledger_providers.dart';

void main() {
  group('Supplier Ledger day-wise grouping and distribution', () {
    test('computes day-wise totals and unique challans correctly', () {
      final day = DateTime(2026, 9, 22);

      final dist1 = SupplierDistributionItem(
        transactionId: 'tx-1',
        deliveryBatchId: 'batch-1',
        challanId: 'ch-1',
        challanNumber: 'CH-2026-000001',
        supplierId: 'sup-1',
        supplierName: 'ABC Textiles',
        productId: 'prod-1',
        productName: 'Silk Saree',
        sku: 'SKU-RED',
        materialType: MaterialType.lace,
        quantity: 100,
        allocationType: AllocationType.newChallan,
        timestamp: DateTime(2026, 9, 22, 10, 30),
      );

      final dist2 = SupplierDistributionItem(
        transactionId: 'tx-2',
        deliveryBatchId: 'batch-1',
        challanId: 'ch-1',
        challanNumber: 'CH-2026-000001',
        supplierId: 'sup-1',
        supplierName: 'ABC Textiles',
        productId: 'prod-1',
        productName: 'Silk Saree',
        sku: 'SKU-RED',
        materialType: MaterialType.blouse,
        quantity: 100,
        allocationType: AllocationType.newChallan,
        timestamp: DateTime(2026, 9, 22, 10, 30),
      );

      final dist3 = SupplierDistributionItem(
        transactionId: 'tx-3',
        deliveryBatchId: 'batch-2',
        challanId: 'ch-2',
        challanNumber: 'CH-2026-000002',
        supplierId: 'sup-1',
        supplierName: 'ABC Textiles',
        productId: 'prod-1',
        productName: 'Silk Saree',
        sku: 'SKU-RED',
        materialType: MaterialType.lace,
        quantity: 20,
        allocationType: AllocationType.oldPendingChallan,
        timestamp: DateTime(2026, 9, 22, 14, 15),
      );

      final ledger = DayWiseSupplierLedger(
        date: day,
        totalSaree: 0,
        totalLace: 120,
        totalBlouse: 100,
        totalTransactions: 3,
        distributions: [dist1, dist2, dist3],
      );

      expect(ledger.totalLace, 120);
      expect(ledger.totalBlouse, 100);
      expect(ledger.totalPieces, 220);
      expect(ledger.uniqueChallansCount, 2);
      expect(ledger.uniqueSuppliersCount, 1);
      expect(ledger.distributions.length, 3);
    });
  });

  group('Stitching Ledger day-wise returns and distribution', () {
    test('computes day-wise return totals and unique challans correctly', () {
      final day = DateTime(2026, 9, 23);

      final dist1 = StitchingDistributionItem(
        transactionId: 'ptx-1',
        challanId: 'ch-1',
        challanNumber: 'CH-2026-000001',
        stitchingUserId: 'unit-1',
        stitchingUserName: 'Ramesh Master',
        productId: 'prod-1',
        productName: 'Silk Saree',
        sku: 'SKU-RED',
        quantity: 50,
        timestamp: DateTime(2026, 9, 23, 11, 0),
        depositRequestId: 'dep-101',
      );

      final dist2 = StitchingDistributionItem(
        transactionId: 'ptx-2',
        challanId: 'ch-2',
        challanNumber: 'CH-2026-000002',
        stitchingUserId: 'unit-1',
        stitchingUserName: 'Ramesh Master',
        productId: 'prod-1',
        productName: 'Silk Saree',
        sku: 'SKU-RED',
        quantity: 35,
        timestamp: DateTime(2026, 9, 23, 15, 30),
        depositRequestId: 'dep-102',
      );

      final ledger = DayWiseStitchingLedger(
        date: day,
        totalReturnedQuantity: 85,
        totalEvents: 2,
        distributions: [dist1, dist2],
      );

      expect(ledger.totalReturnedQuantity, 85);
      expect(ledger.totalEvents, 2);
      expect(ledger.uniqueChallansCount, 2);
      expect(ledger.uniqueStitchingUsersCount, 1);
    });
  });

  group('LedgerDateFilter matching logic', () {
    test('matches today and custom date ranges correctly', () {
      final now = DateTime.now();

      final stateAll = const SupplierLedgerFilterState(dateFilter: LedgerDateFilter.allTime);
      expect(stateAll.matchesDate(now), isTrue);
      expect(stateAll.matchesDate(now.subtract(const Duration(days: 40))), isTrue);

      final stateToday = const SupplierLedgerFilterState(dateFilter: LedgerDateFilter.today);
      expect(stateToday.matchesDate(now), isTrue);
      expect(stateToday.matchesDate(now.subtract(const Duration(days: 2))), isFalse);

      final stateCustom = SupplierLedgerFilterState(
        dateFilter: LedgerDateFilter.custom,
        customStartDate: DateTime(2026, 9, 1),
        customEndDate: DateTime(2026, 9, 30),
      );
      expect(stateCustom.matchesDate(DateTime(2026, 9, 15)), isTrue);
      expect(stateCustom.matchesDate(DateTime(2026, 10, 1)), isFalse);
    });

    test('availableFilters includes allTime only for admin users', () {
      final adminFilters = LedgerDateFilter.availableFilters(isAdmin: true);
      expect(adminFilters, contains(LedgerDateFilter.allTime));
      expect(adminFilters.length, LedgerDateFilter.values.length);

      final nonAdminFilters = LedgerDateFilter.availableFilters(isAdmin: false);
      expect(nonAdminFilters, isNot(contains(LedgerDateFilter.allTime)));
      expect(nonAdminFilters, [
        LedgerDateFilter.today,
        LedgerDateFilter.yesterday,
        LedgerDateFilter.last7Days,
        LedgerDateFilter.thisMonth,
        LedgerDateFilter.custom,
      ]);
    });
  });
}
