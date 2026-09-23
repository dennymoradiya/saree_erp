import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/suppliers/presentation/screens/supplier_pending_materials_screen.dart';

void main() {
  group('SupplierPendingMaterialsScreen', () {
    final testNow = DateTime(2026, 9, 22, 10, 0);

    final testChallan = Challan(
      challanId: 'ch-001',
      challanNumber: 'CH-2026-000001',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-user-1',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: testNow,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final itemWithLaceShortage = ChallanItem(
      challanItemId: 'item-001',
      challanId: 'ch-001',
      productId: 'prod-1',
      sku: 'SKU-001',
      productNameSnapshot: 'Banarasi Brocade Saree',
      skuSnapshot: 'SKU-001',
      colorNameSnapshot: 'Royal Blue',
      sareeIssuedQuantity: 100,
      sareeReturnedQuantity: 0,
      sareePendingQuantity: 100,
      laceRequiredQuantity: 100,
      laceSuppliedQuantity: 80,
      lacePendingSupplierQuantity: 20, // 20 lace pending
      blouseRequiredQuantity: 100,
      blouseSuppliedQuantity: 100,
      blousePendingSupplierQuantity: 0,
      sareeRequiredQuantity: 100,
      sareeSuppliedQuantity: 100,
      sareePendingSupplierQuantity: 0,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final itemWithBlouseShortage = ChallanItem(
      challanItemId: 'item-002',
      challanId: 'ch-001',
      productId: 'prod-2',
      sku: 'SKU-002',
      productNameSnapshot: 'Kanjivaram Silk Saree',
      skuSnapshot: 'SKU-002',
      colorNameSnapshot: 'Emerald Green',
      sareeIssuedQuantity: 50,
      sareeReturnedQuantity: 0,
      sareePendingQuantity: 50,
      laceRequiredQuantity: 50,
      laceSuppliedQuantity: 50,
      lacePendingSupplierQuantity: 0,
      blouseRequiredQuantity: 50,
      blouseSuppliedQuantity: 35,
      blousePendingSupplierQuantity: 15, // 15 blouse pending
      sareeRequiredQuantity: 50,
      sareeSuppliedQuantity: 50,
      sareePendingSupplierQuantity: 0,
      createdAt: testNow,
      updatedAt: testNow,
    );

    testWidgets('renders all pending materials with challan details and totals',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challansStreamProvider(const ChallanFilter(supplierId: 'sup-1'))
                .overrideWith(
              (ref) => Stream.value([testChallan]),
            ),
            pendingSupplierItemsStreamProvider('sup-1').overrideWith(
              (ref) => Stream.value([itemWithLaceShortage, itemWithBlouseShortage]),
            ),
          ],
          child: const MaterialApp(
            home: SupplierPendingMaterialsScreen(
              supplierId: 'sup-1',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and item contents
      expect(find.text('Pending Materials to Provide'), findsOneWidget);
      expect(find.text('CH-2026-000001'), findsNWidgets(2));
      expect(find.text('Banarasi Brocade Saree'), findsOneWidget);
      expect(find.text('Kanjivaram Silk Saree'), findsOneWidget);

      // Check pending counts
      expect(find.text('Pending: 20'), findsOneWidget); // Lace shortage
      expect(find.text('Pending: 15'), findsOneWidget); // Blouse shortage

      // Check action buttons
      expect(find.text('Supply Material'), findsNWidgets(2));
      expect(find.text('View Challan'), findsNWidgets(2));
    });

    testWidgets('filters by lace when initialMaterialType is lace',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challansStreamProvider(const ChallanFilter(supplierId: 'sup-1'))
                .overrideWith(
              (ref) => Stream.value([testChallan]),
            ),
            pendingSupplierItemsStreamProvider('sup-1').overrideWith(
              (ref) => Stream.value([itemWithLaceShortage, itemWithBlouseShortage]),
            ),
          ],
          child: const MaterialApp(
            home: SupplierPendingMaterialsScreen(
              supplierId: 'sup-1',
              initialMaterialType: MaterialType.lace,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only Banarasi Brocade Saree (with lace pending) should be shown
      expect(find.text('Banarasi Brocade Saree'), findsOneWidget);
      expect(find.text('Kanjivaram Silk Saree'), findsNothing);
      expect(find.text('1 Pending Challan Line Item'), findsOneWidget);
    });

    testWidgets('filters by blouse when initialMaterialType is blouse',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challansStreamProvider(const ChallanFilter(supplierId: 'sup-1'))
                .overrideWith(
              (ref) => Stream.value([testChallan]),
            ),
            pendingSupplierItemsStreamProvider('sup-1').overrideWith(
              (ref) => Stream.value([itemWithLaceShortage, itemWithBlouseShortage]),
            ),
          ],
          child: const MaterialApp(
            home: SupplierPendingMaterialsScreen(
              supplierId: 'sup-1',
              initialMaterialType: MaterialType.blouse,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only Kanjivaram Silk Saree (with blouse pending) should be shown
      expect(find.text('Banarasi Brocade Saree'), findsNothing);
      expect(find.text('Kanjivaram Silk Saree'), findsOneWidget);
      expect(find.text('1 Pending Challan Line Item'), findsOneWidget);
    });
  });
}
