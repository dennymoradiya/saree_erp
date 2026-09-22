import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

void main() {
  group('SupplierMaterialTransaction serialization', () {
    test('serializes and deserializes transaction with date and notes', () {
      final now = DateTime(2026, 9, 22, 10, 30);
      final tx = SupplierMaterialTransaction(
        transactionId: 'tx-001',
        deliveryBatchId: 'batch-001',
        supplierId: 'sup-1',
        productId: 'prod-1',
        sku: 'SKU-RED',
        materialType: MaterialType.lace,
        quantity: 100,
        challanId: 'ch-001',
        challanItemId: 'item-001',
        allocationType: AllocationType.newChallan,
        createdBy: 'user-admin',
        createdAt: now,
        notes: 'Initial delivery of 100 lace pieces',
      );

      final json = tx.toJson();
      expect(json['transactionId'], 'tx-001');
      expect(json['materialType'], 'LACE');
      expect(json['quantity'], 100.0);
      expect(json['allocationType'], 'NEW_CHALLAN');
      expect(json['notes'], 'Initial delivery of 100 lace pieces');

      final deserialized = SupplierMaterialTransaction.fromJson(json);
      expect(deserialized.transactionId, tx.transactionId);
      expect(deserialized.materialType, MaterialType.lace);
      expect(deserialized.quantity, 100.0);
      expect(deserialized.notes, 'Initial delivery of 100 lace pieces');
      expect(deserialized.createdAt.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch);
    });

    test('handles remaining material fulfillment transaction', () {
      final now = DateTime(2026, 9, 22, 14, 0);
      final tx = SupplierMaterialTransaction(
        transactionId: 'tx-002',
        deliveryBatchId: 'batch-002',
        supplierId: 'sup-1',
        productId: 'prod-1',
        sku: 'SKU-RED',
        materialType: MaterialType.lace,
        quantity: 20,
        challanId: 'ch-001',
        challanItemId: 'item-001',
        allocationType: AllocationType.oldPendingChallan,
        allocationReferenceId: 'item-001',
        createdBy: 'user-admin',
        createdAt: now,
        notes: 'Completed remaining 20 lace pieces',
      );

      final json = tx.toJson();
      expect(json['materialType'], 'LACE');
      expect(json['quantity'], 20.0);
      expect(json['allocationType'], 'OLD_PENDING_CHALLAN');
      expect(json['allocationReferenceId'], 'item-001');
      expect(json['notes'], 'Completed remaining 20 lace pieces');

      final deserialized = SupplierMaterialTransaction.fromJson(json);
      expect(deserialized.quantity, 20.0);
      expect(deserialized.allocationType, AllocationType.oldPendingChallan);
    });
  });
}
