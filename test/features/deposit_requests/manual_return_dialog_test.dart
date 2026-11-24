import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request_repository.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/screens/deposit_requests_screen.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class _ManualReturnRepository implements DepositRequestRepository {
  List<DepositRequestItem>? recordedItems;
  String? recordedUser;
  DateTime? recordedDate;
  bool pendingPink = true;

  @override
  Future<Result<bool>> hasSameDayPendingDepositRequest({
    required String stitchingUserId,
    required String productId,
    required String sku,
  }) async =>
      Success(pendingPink && sku == 'PINK');

  @override
  Future<Result<List<String>>> recordManualAdminReturns({
    required String stitchingUserId,
    required List<DepositRequestItem> items,
    String? notes,
    DateTime? occurredAt,
  }) async {
    recordedItems = items;
    recordedUser = stitchingUserId;
    recordedDate = occurredAt;
    return const Success(['tx-green', 'tx-pink']);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'validates every row and submits all colours in one manual return',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final repo = _ManualReturnRepository();
    final product = Product(
      productId: 'silk',
      name: 'Silk Saree',
      productCode: 'SILK',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final user = StitchingUserProfile(
      stitchingUserId: 'unit-1',
      name: 'Patel Stitching',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    const skus = [
      ProductSku(
        productId: 'silk',
        sku: 'GREEN',
        colorName: 'Green',
        isActive: true,
      ),
      ProductSku(
        productId: 'silk',
        sku: 'PINK',
        colorName: 'Pink',
        isActive: true,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          depositRequestRepositoryProvider.overrideWithValue(repo),
          stitchingUsersListProvider
              .overrideWith((ref) => Stream.value([user])),
          productsStreamProvider.overrideWith((ref) => Stream.value([product])),
          productSkusStreamProvider('silk')
              .overrideWith((ref) => Stream.value(skus)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showManualReturnDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    Future<void> select(Finder field, String option) async {
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await select(
      find.byType(DropdownButtonFormField<StitchingUserProfile>),
      'Patel Stitching',
    );
    await select(
      find.byType(DropdownButtonFormField<Product>),
      'Silk Saree (SILK)',
    );
    await select(
      find.byType(DropdownButtonFormField<ProductSku>),
      'Green (GREEN)',
    );
    final quantities =
        find.widgetWithText(TextFormField, 'Finished Sarees Returned *');
    await tester.enterText(quantities.first, '100');
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    await select(
      find.byType(DropdownButtonFormField<Product>).last,
      'Silk Saree (SILK)',
    );
    await select(
      find.byType(DropdownButtonFormField<ProductSku>).last,
      'Pink (PINK)',
    );

    await tester.enterText(quantities.last, 'NaN');
    await tester.tap(find.text('Record Return'));
    await tester.pumpAndSettle();
    expect(repo.recordedItems, isNull);
    expect(find.text('Valid positive quantity required'), findsOneWidget);

    await tester.enterText(quantities.last, '50');
    await tester.tap(find.text('Record Return'));
    await tester.pumpAndSettle();
    expect(repo.recordedItems, isNull);
    expect(find.textContaining('unverified deposit request'), findsOneWidget);
    repo.pendingPink = false;
    await tester.tap(find.text('Record Return'));
    await tester.pumpAndSettle();
    expect(repo.recordedUser, 'unit-1');
    expect(repo.recordedDate, isNotNull);
    expect(repo.recordedItems, [
      const DepositRequestItem(
        productId: 'silk',
        sku: 'GREEN',
        requestedQuantity: 100,
      ),
      const DepositRequestItem(
        productId: 'silk',
        sku: 'PINK',
        requestedQuantity: 50,
      ),
    ]);
    expect(find.byType(ManualReturnDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
