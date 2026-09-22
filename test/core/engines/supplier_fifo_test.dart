import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/engines/supplier_fifo.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';

void main() {
  group('allocateSupplierMaterialFIFO', () {
    test('settles oldest pending material first', () {
      final items = [
        const SupplierPendingChallanItem(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          pendingQuantity: 20.0,
          createdAtMillis: 2000,
        ),
        const SupplierPendingChallanItem(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          pendingQuantity: 15.0,
          createdAtMillis: 1000,
        ),
      ];

      final result = allocateSupplierMaterialFIFO(
        pendingItems: items,
        suppliedQuantity: 25.0,
      );

      expect(result.allocations, [
        const SupplierAllocationResult(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          allocatedQuantity: 15.0,
          allocationType: AllocationType.oldPendingChallan,
        ),
        const SupplierAllocationResult(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          allocatedQuantity: 10.0,
          allocationType: AllocationType.oldPendingChallan,
        ),
      ]);
      expect(result.remainingForNewChallan, 0.0);
    });

    test('computes leftover remaining for new challan when old pending is exhausted', () {
      final items = [
        const SupplierPendingChallanItem(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          pendingQuantity: 10.0,
          createdAtMillis: 1000,
        ),
      ];

      final result = allocateSupplierMaterialFIFO(
        pendingItems: items,
        suppliedQuantity: 25.0,
      );

      expect(result.allocations, [
        const SupplierAllocationResult(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          allocatedQuantity: 10.0,
          allocationType: AllocationType.oldPendingChallan,
        ),
      ]);
      expect(result.remainingForNewChallan, 15.0);
    });

    test('rejects negative supplied quantity', () {
      expect(
        () => allocateSupplierMaterialFIFO(
          pendingItems: [],
          suppliedQuantity: -1.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
