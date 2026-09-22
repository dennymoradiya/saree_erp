import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/engines/stitching_fifo.dart';

void main() {
  group('allocateStitchingReturnFIFO', () {
    test('settles oldest challan items first according to createdAtMillis', () {
      final items = [
        const StitchingPendingChallanItem(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          sareePendingQuantity: 10.0,
          createdAtMillis: 2000,
        ),
        const StitchingPendingChallanItem(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          sareePendingQuantity: 5.0,
          createdAtMillis: 1000,
        ),
      ];

      final results = allocateStitchingReturnFIFO(
        pendingItems: items,
        returnedFinishedQuantity: 8.0,
      );

      expect(results, [
        const StitchingAllocationResult(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          allocatedQuantity: 5.0,
        ),
        const StitchingAllocationResult(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          allocatedQuantity: 3.0,
        ),
      ]);
    });

    test('rejects return quantity that exceeds total eligible pending', () {
      final items = [
        const StitchingPendingChallanItem(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          sareePendingQuantity: 5.0,
          createdAtMillis: 1000,
        ),
      ];

      expect(
        () => allocateStitchingReturnFIFO(
          pendingItems: items,
          returnedFinishedQuantity: 6.0,
        ),
        throwsStateError,
      );
    });

    test('rejects zero or negative return quantity', () {
      expect(
        () => allocateStitchingReturnFIFO(
          pendingItems: [],
          returnedFinishedQuantity: 0.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => allocateStitchingReturnFIFO(
          pendingItems: [],
          returnedFinishedQuantity: -5.0,
        ),
        throwsArgumentError,
      );
    });

    test('ignores items with zero pending quantity', () {
      final items = [
        const StitchingPendingChallanItem(
          challanId: 'ch-1',
          challanItemId: 'item-1',
          sareePendingQuantity: 0.0,
          createdAtMillis: 1000,
        ),
        const StitchingPendingChallanItem(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          sareePendingQuantity: 10.0,
          createdAtMillis: 2000,
        ),
      ];

      final results = allocateStitchingReturnFIFO(
        pendingItems: items,
        returnedFinishedQuantity: 4.0,
      );

      expect(results, [
        const StitchingAllocationResult(
          challanId: 'ch-2',
          challanItemId: 'item-2',
          allocatedQuantity: 4.0,
        ),
      ]);
    });
  });
}
