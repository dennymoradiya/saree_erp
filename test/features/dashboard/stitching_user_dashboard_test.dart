import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/features/auth/domain/app_user.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/dashboard/presentation/screens/stitching_user_dashboard_screen.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';

void main() {
  group('StitchingUserDashboardScreen', () {
    final now = DateTime.now();
    final currentMonthDate = DateTime(now.year, now.month, 10, 10, 0);
    final previousMonthDate = DateTime(now.year, now.month - 1, 15, 10, 0);

    final stitchingAuthUser = AppUser(
      uid: 'user-001',
      email: 'radhe@example.com',
      phone: '9876543210',
      name: 'Radhe Stitching Works',
      role: UserRole.stitchingUser,
      stitchingUserId: 'stitch-001',
      isActive: true,
      createdAt: currentMonthDate,
      updatedAt: currentMonthDate,
    );

    final currentIncompleteChallan = Challan(
      challanId: 'ch-curr-incomplete',
      challanNumber: 'CH-CURR-001',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: currentMonthDate,
      createdAt: currentMonthDate,
      updatedAt: currentMonthDate,
    );

    final currentCompletedChallan = Challan(
      challanId: 'ch-curr-completed',
      challanNumber: 'CH-CURR-002',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.completed,
      issuedAt: currentMonthDate,
      createdAt: currentMonthDate,
      updatedAt: currentMonthDate,
    );

    final pastMonthChallan = Challan(
      challanId: 'ch-past-001',
      challanNumber: 'CH-PAST-001',
      supplierId: 'sup-1',
      stitchingUserId: 'stitch-001',
      createdBy: 'admin-1',
      createdByRole: 'ADMIN',
      status: ChallanStatus.issued,
      issuedAt: previousMonthDate,
      createdAt: previousMonthDate,
      updatedAt: previousMonthDate,
    );

    testWidgets('shows current month challans and red border for incomplete challans',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(stitchingAuthUser),
            ),
            challansStreamProvider(const ChallanFilter(stitchingUserId: 'stitch-001'))
                .overrideWith(
              (ref) => Stream.value([
                currentIncompleteChallan,
                currentCompletedChallan,
                pastMonthChallan,
              ]),
            ),
            depositRequestsStreamProvider(
              const DepositRequestFilter(stitchingUserId: 'stitch-001'),
            ).overrideWith((ref) => Stream.value(<DepositRequest>[])),
          ],
          child: const MaterialApp(
            home: StitchingUserDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify current month challans are present
      expect(find.text('CH-CURR-001'), findsOneWidget);
      expect(find.text('CH-CURR-002'), findsOneWidget);

      // Verify past month challan is filtered out
      expect(find.text('CH-PAST-001'), findsNothing);

      // Verify incomplete challan has red border
      final incompleteListTileFinder = find.ancestor(
        of: find.text('CH-CURR-001'),
        matching: find.byType(ListTile),
      );
      final incompleteListTile = tester.widget<ListTile>(incompleteListTileFinder);
      final incompleteShape = incompleteListTile.shape as RoundedRectangleBorder;
      expect(incompleteShape.side.color, Colors.red.shade400);

      // Verify completed challan has grey border
      final completedListTileFinder = find.ancestor(
        of: find.text('CH-CURR-002'),
        matching: find.byType(ListTile),
      );
      final completedListTile = tester.widget<ListTile>(completedListTileFinder);
      final completedShape = completedListTile.shape as RoundedRectangleBorder;
      expect(completedShape.side.color, Colors.grey.shade200);
    });
  });
}
