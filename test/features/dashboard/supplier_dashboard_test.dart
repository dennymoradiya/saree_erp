import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/dashboard/presentation/screens/supplier_dashboard_screen.dart';

void main() {
  group('SupplierDashboardScreen', () {
    final now = DateTime(2026, 9, 22, 10, 0);

    final supplierUser = AppUser(
      uid: 'user-sup-001',
      email: 'supplier@example.com',
      phone: '9876543210',
      name: 'Surat Fabrics',
      role: UserRole.supplier,
      supplierId: 'sup-001',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final challanWithShortage = Challan(
      challanId: 'ch-pending-01',
      challanNumber: 'CH-PENDING-001',
      supplierId: 'sup-001',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    final challanCompletedShortage = Challan(
      challanId: 'ch-complete-01',
      challanNumber: 'CH-COMPLETE-001',
      supplierId: 'sup-001',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    final pendingItem = ChallanItem(
      challanItemId: 'item-001',
      challanId: 'ch-pending-01',
      productId: 'prod-001',
      sku: 'SKU-001',
      productNameSnapshot: 'Chiffon Saree',
      skuSnapshot: 'SKU-001',
      colorNameSnapshot: 'Red',
      sareeIssuedQuantity: 100,
      sareeReturnedQuantity: 0,
      sareePendingQuantity: 100,
      laceRequiredQuantity: 100,
      laceSuppliedQuantity: 80,
      lacePendingSupplierQuantity: 20, // 20 lace shortage!
      blouseRequiredQuantity: 100,
      blouseSuppliedQuantity: 100,
      blousePendingSupplierQuantity: 0,
      sareeRequiredQuantity: 100,
      sareeSuppliedQuantity: 100,
      sareePendingSupplierQuantity: 0,
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('shows red border for challans with pending supplier materials',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(supplierUser),
            ),
            challansStreamProvider(const ChallanFilter(supplierId: 'sup-001'))
                .overrideWith(
              (ref) => Stream.value([
                challanWithShortage,
                challanCompletedShortage,
              ]),
            ),
            pendingSupplierItemsStreamProvider('sup-001').overrideWith(
              (ref) => Stream.value([pendingItem]),
            ),
          ],
          child: const MaterialApp(
            home: SupplierDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check both challan numbers appear
      expect(find.text('CH-PENDING-001'), findsOneWidget);
      expect(find.text('CH-COMPLETE-001'), findsOneWidget);

      // Verify shortage badge and text appear
      expect(find.text('Pending Shortage'), findsOneWidget);
      expect(find.text('Pending: 20 Lace'), findsOneWidget);

      // Verify red border on challan with shortage
      final shortageTileFinder = find.ancestor(
        of: find.text('CH-PENDING-001'),
        matching: find.byType(ListTile),
      );
      final shortageTile = tester.widget<ListTile>(shortageTileFinder);
      final shortageShape = shortageTile.shape as RoundedRectangleBorder;
      expect(shortageShape.side.color, Colors.red.shade400);

      // Verify normal grey border on challan without shortage
      final completeTileFinder = find.ancestor(
        of: find.text('CH-COMPLETE-001'),
        matching: find.byType(ListTile),
      );
      final completeTile = tester.widget<ListTile>(completeTileFinder);
      final completeShape = completeTile.shape as RoundedRectangleBorder;
      expect(completeShape.side.color, Colors.grey.shade200);
    });
  });
}
