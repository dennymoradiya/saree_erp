import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/utils/whatsapp_share_helper.dart';

void main() {
  group('WhatsAppShareHelper.formatChallanMessage', () {
    test('formats complete challan message with items and shortages', () {
      final message = WhatsAppShareHelper.formatChallanMessage(
        challanNumber: 'CH-2026-000001',
        createdAt: DateTime(2026, 9, 21, 15, 30),
        supplierName: 'ABC Textiles',
        stitchingUserName: 'Master Stitcher',
        notes: 'Priority festive batch',
        items: const [
          ChallanItemShareData(
            productName: 'Banarasi Saree',
            sku: 'BAN001-RED',
            colorName: 'Crimson Red',
            targetQuantity: 100,
            sareeSupplied: 100,
            laceSupplied: 80,
            blouseSupplied: 70,
            sareePending: 0,
            lacePending: 20,
            blousePending: 30,
            requiresLace: true,
            requiresBlouse: true,
          ),
        ],
      );

      expect(message, contains('CH-2026-000001'));
      expect(message, contains('ABC Textiles'));
      expect(message, contains('Master Stitcher'));
      expect(message, contains('Priority festive batch'));
      expect(message, contains('Banarasi Saree — BAN001-RED (Crimson Red)'));
      expect(message, contains('Target Sarees: 100'));
      expect(message, contains('Base Saree Fabric Delivered: 100 pcs'));
      expect(message, contains('Lace Delivered: 80 pcs'));
      expect(message, contains('Blouse Delivered: 70 pcs'));
      expect(message, contains('Lace Pending (from Supplier): 20 pcs'));
      expect(message, contains('Blouse Pending (from Supplier): 30 pcs'));
      expect(message, contains('Verified via Saree Sutra Material Accounting'));
    });

    test('formats raw-saree-only product message without lace or blouse', () {
      final message = WhatsAppShareHelper.formatChallanMessage(
        challanNumber: 'CH-2026-000002',
        createdAt: DateTime(2026, 9, 21, 15, 30),
        supplierName: 'Cotton Mills',
        stitchingUserName: 'Handloom Stitching',
        items: const [
          ChallanItemShareData(
            productName: 'Pure Cotton Plain Saree',
            sku: 'COT-WHT',
            colorName: 'White',
            targetQuantity: 50,
            sareeSupplied: 50,
            laceSupplied: 0,
            blouseSupplied: 0,
            sareePending: 0,
            lacePending: 0,
            blousePending: 0,
            requiresLace: false,
            requiresBlouse: false,
          ),
        ],
      );

      expect(message, contains('Pure Cotton Plain Saree — COT-WHT (White)'));
      expect(message, contains('Base Saree Fabric Delivered: 50 pcs'));
      expect(message, isNot(contains('Lace Delivered')));
      expect(message, isNot(contains('Blouse Delivered')));
      expect(message, isNot(contains('Pending Shortage')));
    });

    test('formats lace/blouse first delivery where admin owes plain saree', () {
      final message = WhatsAppShareHelper.formatChallanMessage(
        challanNumber: 'CH-2026-000003',
        createdAt: DateTime(2026, 9, 21, 15, 30),
        supplierName: 'Zari Trims Co',
        stitchingUserName: 'Fashion Stitchers',
        items: const [
          ChallanItemShareData(
            productName: 'Georgette Embroidered',
            sku: 'GEO-01',
            targetQuantity: 100,
            sareeSupplied: 0,
            laceSupplied: 100,
            blouseSupplied: 100,
            sareePending: 100,
            lacePending: 0,
            blousePending: 0,
            requiresLace: true,
            requiresBlouse: true,
          ),
        ],
      );

      expect(message, contains('Base Saree Fabric Delivered: 0 pcs'));
      expect(message, contains('Lace Delivered: 100 pcs'));
      expect(message, contains('Blouse Delivered: 100 pcs'));
      expect(message, contains('Saree Fabric Pending (from Admin): 100 pcs'));
    });
  });
}
