import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/stitching_ledger/presentation/screens/pending_returns_ledger_screen.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

void main() {
  group('PendingReturnsLedger', () {
    final testNow = DateTime(2026, 9, 22, 10, 0);

    final stitchingUser1 = StitchingUserProfile(
      stitchingUserId: 'stitch-001',
      name: 'Patel Stitching Unit',
      phone: '9876543210',
      isActive: true,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final stitchingUser2 = StitchingUserProfile(
      stitchingUserId: 'stitch-002',
      name: 'Sharma Embroidery Works',
      phone: '9876543211',
      isActive: true,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final challan1 = Challan(
      challanId: 'ch-101',
      challanNumber: 'CH-2026-000101',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: testNow,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final challan2 = Challan(
      challanId: 'ch-102',
      challanNumber: 'CH-2026-000102',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-002',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: testNow,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final pendingItem1 = ChallanItem(
      challanItemId: 'item-101',
      challanId: 'ch-101',
      productId: 'prod-silk',
      sku: 'SILK-RED',
      productNameSnapshot: 'Pure Silk Saree',
      skuSnapshot: 'SILK-RED',
      colorNameSnapshot: 'Ruby Red',
      sareeIssuedQuantity: 100,
      sareeReturnedQuantity: 60,
      sareePendingQuantity: 40, // 40 pending at stitch-001
      laceRequiredQuantity: 100,
      laceSuppliedQuantity: 100,
      lacePendingSupplierQuantity: 0,
      blouseRequiredQuantity: 100,
      blouseSuppliedQuantity: 100,
      blousePendingSupplierQuantity: 0,
      sareeRequiredQuantity: 100,
      sareeSuppliedQuantity: 100,
      sareePendingSupplierQuantity: 0,
      createdAt: testNow,
      updatedAt: testNow,
    );

    final pendingItem2 = ChallanItem(
      challanItemId: 'item-102',
      challanId: 'ch-102',
      productId: 'prod-cotton',
      sku: 'COTTON-BLUE',
      productNameSnapshot: 'Chanderi Cotton Saree',
      skuSnapshot: 'COTTON-BLUE',
      colorNameSnapshot: 'Navy Blue',
      sareeIssuedQuantity: 80,
      sareeReturnedQuantity: 50,
      sareePendingQuantity: 30, // 30 pending at stitch-002
      laceRequiredQuantity: 80,
      laceSuppliedQuantity: 80,
      lacePendingSupplierQuantity: 0,
      blouseRequiredQuantity: 80,
      blouseSuppliedQuantity: 80,
      blousePendingSupplierQuantity: 0,
      sareeRequiredQuantity: 80,
      sareeSuppliedQuantity: 80,
      sareePendingSupplierQuantity: 0,
      createdAt: testNow,
      updatedAt: testNow,
    );

    testWidgets('stitching user view shows product pending to return and return action',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockStitchingUser = AppUser(
        uid: 'auth-001',
        email: 'patel@example.com',
        name: 'Patel Stitching Unit',
        role: UserRole.stitchingUser,
        stitchingUserId: 'stitch-001',
        isActive: true,
        createdAt: testNow,
        updatedAt: testNow,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(mockStitchingUser)),
            challansStreamProvider(const ChallanFilter()).overrideWith(
              (ref) => Stream.value([challan1, challan2]),
            ),
            pendingStitchingItemsStreamProvider(null).overrideWith(
              (ref) => Stream.value([pendingItem1, pendingItem2]),
            ),
            stitchingUsersListProvider.overrideWith(
              (ref) => Stream.value([stitchingUser1, stitchingUser2]),
            ),
          ],
          child: const MaterialApp(
            home: PendingReturnsLedgerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title check
      expect(find.text('My Pending Products to Return'), findsOneWidget);
      // Banner and Product card pending total for stitch-001 should be 40 pcs
      expect(find.text('40 pcs'), findsNWidgets(2));

      // Product card details
      expect(find.text('Pure Silk Saree'), findsOneWidget);
      expect(find.text('SKU: SILK-RED'), findsOneWidget);
      expect(find.text('Ruby Red'), findsOneWidget);
      expect(find.text('Pending Return'), findsOneWidget);

      // Return action button for this product
      expect(find.text('Return This Product'), findsOneWidget);

      // Other unit's product shouldn't be in stitch-001's view
      expect(find.text('Chanderi Cotton Saree'), findsNothing);
    });

    testWidgets('admin view shows user-wise pending stock for all stitching units',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockAdminUser = AppUser(
        uid: 'admin-uid',
        email: 'admin@example.com',
        name: 'System Admin',
        role: UserRole.admin,
        isActive: true,
        createdAt: testNow,
        updatedAt: testNow,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(mockAdminUser)),
            challansStreamProvider(const ChallanFilter()).overrideWith(
              (ref) => Stream.value([challan1, challan2]),
            ),
            pendingStitchingItemsStreamProvider(null).overrideWith(
              (ref) => Stream.value([pendingItem1, pendingItem2]),
            ),
            stitchingUsersListProvider.overrideWith(
              (ref) => Stream.value([stitchingUser1, stitchingUser2]),
            ),
          ],
          child: const MaterialApp(
            home: PendingReturnsLedgerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title check
      expect(find.text('Pending Products to Return'), findsOneWidget);
      // Admin overall pending: 40 + 30 = 70 pcs
      expect(find.text('70 pcs'), findsOneWidget);

      // Tab 1 is "By Stitching Unit" (User-wise)
      expect(find.text('Patel Stitching Unit'), findsOneWidget);
      expect(find.text('Sharma Embroidery Works'), findsOneWidget);
      expect(find.text('40 pending'), findsOneWidget);
      expect(find.text('30 pending'), findsOneWidget);

      // Check Tabs presence
      expect(find.text('By Stitching Unit'), findsOneWidget);
      expect(find.text('By Product'), findsOneWidget);
      expect(find.text('By Challan'), findsOneWidget);
    });
  });
}
