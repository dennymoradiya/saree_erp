import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/features/challans/domain/create_challan_input.dart';

void main() {
  group('CreateChallanInput auto-split', () {
    test(
        'creates a second challan for the remaining shortage when partial supply is entered',
        () {
      final input = CreateChallanInput(
        supplierId: 'supplier-1',
        stitchingUserId: 'stitching-1',
        items: [
          CreateChallanItemInput(
            productId: 'product-1',
            sku: 'SKU-1',
            productNameSnapshot: 'Cotton Saree',
            skuSnapshot: 'SKU-1',
            colorNameSnapshot: 'Red',
            requiresSaree: true,
            requiresLace: true,
            requiresBlouse: true,
            sareeIssuedQuantity: 100,
            sareeSuppliedQuantity: 30,
            laceSuppliedQuantity: 0,
            blouseSuppliedQuantity: 20,
          ),
        ],
        notes: 'Partial dispatch',
      );

      final splits = input.splitForAutoChallan();

      expect(splits.length, 2);
      expect(splits[0].items.first.sareeSuppliedQuantity, 30);
      expect(splits[1].items.first.sareeIssuedQuantity, 70);
      expect(splits[1].items.first.sareeSuppliedQuantity, 70);
      expect(splits[1].notes, 'Auto-created remaining challan for shortage');
    });

    test('treats blank supplied values as zero and creates a second challan',
        () {
      final input = CreateChallanInput(
        supplierId: 'supplier-1',
        stitchingUserId: 'stitching-1',
        items: [
          CreateChallanItemInput(
            productId: 'product-1',
            sku: 'SKU-1',
            productNameSnapshot: 'Cotton Saree',
            skuSnapshot: 'SKU-1',
            colorNameSnapshot: 'Red',
            requiresSaree: true,
            requiresLace: true,
            requiresBlouse: true,
            sareeIssuedQuantity: 50,
            sareeSuppliedQuantity: 0,
            laceSuppliedQuantity: 0,
            blouseSuppliedQuantity: 0,
          ),
        ],
      );

      final splits = input.splitForAutoChallan();
      expect(splits.length, 2);
      expect(splits[0].items.first.sareeSuppliedQuantity, 0);
      expect(splits[1].items.first.sareeIssuedQuantity, 50);
    });

    test('keeps a single challan when there is no shortage to auto-split', () {
      final input = CreateChallanInput(
        supplierId: 'supplier-1',
        stitchingUserId: 'stitching-1',
        items: [
          CreateChallanItemInput(
            productId: 'product-1',
            sku: 'SKU-1',
            productNameSnapshot: 'Cotton Saree',
            skuSnapshot: 'SKU-1',
            colorNameSnapshot: 'Red',
            requiresSaree: true,
            requiresLace: false,
            requiresBlouse: false,
            sareeIssuedQuantity: 40,
            sareeSuppliedQuantity: 40,
            laceSuppliedQuantity: 0,
            blouseSuppliedQuantity: 0,
          ),
        ],
      );

      expect(input.splitForAutoChallan().length, 1);
    });
  });
}
