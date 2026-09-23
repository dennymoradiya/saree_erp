import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/pending_returns_ledger_models.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

/// Provider for the selected stitching user filter on the Pending Returns Ledger.
/// null means "All Stitching Units".
final pendingReturnsUserFilterProvider =
    StateProvider.family<String?, String?>((ref, initialUser) => initialUser);

/// Aggregated provider that builds user-wise and product-wise pending returns ledger data.
final pendingReturnsLedgerDataProvider =
    Provider.family<AsyncValue<PendingReturnsLedgerData>, String?>(
        (ref, userFilter) {
  final challansAsync =
      ref.watch(challansStreamProvider(const ChallanFilter()));
  final pendingItemsAsync =
      ref.watch(pendingStitchingItemsStreamProvider(null));
  final usersAsync = ref.watch(stitchingUsersListProvider);

  if (challansAsync.isLoading ||
      pendingItemsAsync.isLoading ||
      usersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (challansAsync.hasError) {
    return AsyncValue.error(challansAsync.error!, challansAsync.stackTrace!);
  }
  if (pendingItemsAsync.hasError) {
    return AsyncValue.error(
        pendingItemsAsync.error!, pendingItemsAsync.stackTrace!);
  }
  if (usersAsync.hasError) {
    return AsyncValue.error(usersAsync.error!, usersAsync.stackTrace!);
  }

  final challans = challansAsync.value ?? [];
  final pendingItems = pendingItemsAsync.value ?? [];
  final users = usersAsync.value ?? [];

  final challansMap = {for (final c in challans) c.challanId: c};
  final usersMap = {for (final u in users) u.stitchingUserId: u};

  // 1. Build flattened list of pending return challan items
  final allItems = <PendingReturnChallanItem>[];
  for (final item in pendingItems) {
    if (item.sareePendingQuantity <= 0) continue;

    final challan = challansMap[item.challanId];
    if (challan == null) continue;

    // Apply user filter if specified
    if (userFilter != null &&
        userFilter.isNotEmpty &&
        challan.stitchingUserId != userFilter) {
      continue;
    }

    final userProfile = usersMap[challan.stitchingUserId];
    final userName = userProfile?.name ?? challan.stitchingUserId;

    allItems.add(
      PendingReturnChallanItem(
        challanItemId: item.challanItemId,
        challanId: item.challanId,
        challanNumber: challan.challanNumber,
        issuedAt: challan.issuedAt,
        stitchingUserId: challan.stitchingUserId,
        stitchingUserName: userName,
        productId: item.productId,
        sku: item.skuSnapshot,
        productName: item.productNameSnapshot,
        color: item.colorNameSnapshot,
        issuedQuantity: item.sareeIssuedQuantity,
        returnedQuantity: item.sareeReturnedQuantity,
        pendingQuantity: item.sareePendingQuantity,
      ),
    );
  }

  // Sort items newest first
  allItems.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

  // 2. Aggregate by Product
  final productGroups = <String, List<PendingReturnChallanItem>>{};
  for (final it in allItems) {
    final key = '${it.productId}_${it.sku}_${it.color ?? ''}';
    productGroups.putIfAbsent(key, () => []).add(it);
  }

  final productSummaries = <ProductPendingReturn>[];
  for (final entry in productGroups.entries) {
    final list = entry.value;
    final first = list.first;

    var totalIssued = 0.0;
    var totalReturned = 0.0;
    var totalPending = 0.0;
    final userPendingMap = <String, double>{};

    for (final it in list) {
      totalIssued += it.issuedQuantity;
      totalReturned += it.returnedQuantity;
      totalPending += it.pendingQuantity;
      userPendingMap[it.stitchingUserId] =
          (userPendingMap[it.stitchingUserId] ?? 0) + it.pendingQuantity;
    }

    productSummaries.add(
      ProductPendingReturn(
        productId: first.productId,
        sku: first.sku,
        productName: first.productName,
        color: first.color,
        totalIssued: totalIssued,
        totalReturned: totalReturned,
        totalPending: totalPending,
        items: list,
        userPendingMap: userPendingMap,
      ),
    );
  }

  // Sort products descending by total pending
  productSummaries.sort((a, b) => b.totalPending.compareTo(a.totalPending));

  // 3. Aggregate by User (Stitching Unit)
  final userGroups = <String, List<PendingReturnChallanItem>>{};
  for (final it in allItems) {
    userGroups.putIfAbsent(it.stitchingUserId, () => []).add(it);
  }

  final userSummaries = <UserPendingReturn>[];
  for (final entry in userGroups.entries) {
    final userId = entry.key;
    final list = entry.value;
    final userProfile = usersMap[userId];
    final userName = userProfile?.name ?? userId;

    var totalIssued = 0.0;
    var totalReturned = 0.0;
    var totalPending = 0.0;

    // Group items under this user by product
    final userProductGroups = <String, List<PendingReturnChallanItem>>{};
    for (final it in list) {
      totalIssued += it.issuedQuantity;
      totalReturned += it.returnedQuantity;
      totalPending += it.pendingQuantity;
      final pKey = '${it.productId}_${it.sku}_${it.color ?? ''}';
      userProductGroups.putIfAbsent(pKey, () => []).add(it);
    }

    final userProducts = <ProductPendingReturn>[];
    for (final pEntry in userProductGroups.entries) {
      final pList = pEntry.value;
      final pFirst = pList.first;
      var pIssued = 0.0;
      var pReturned = 0.0;
      var pPending = 0.0;
      for (final pIt in pList) {
        pIssued += pIt.issuedQuantity;
        pReturned += pIt.returnedQuantity;
        pPending += pIt.pendingQuantity;
      }
      userProducts.add(
        ProductPendingReturn(
          productId: pFirst.productId,
          sku: pFirst.sku,
          productName: pFirst.productName,
          color: pFirst.color,
          totalIssued: pIssued,
          totalReturned: pReturned,
          totalPending: pPending,
          items: pList,
          userPendingMap: {userId: pPending},
        ),
      );
    }

    userProducts.sort((a, b) => b.totalPending.compareTo(a.totalPending));

    userSummaries.add(
      UserPendingReturn(
        stitchingUserId: userId,
        userName: userName,
        userPhone: userProfile?.phone,
        totalIssued: totalIssued,
        totalReturned: totalReturned,
        totalPending: totalPending,
        products: userProducts,
        items: list,
      ),
    );
  }

  // Sort users descending by total pending
  userSummaries.sort((a, b) => b.totalPending.compareTo(a.totalPending));

  // 4. Compute overall totals
  var grandIssued = 0.0;
  var grandReturned = 0.0;
  var grandPending = 0.0;
  final uniqueChallans = <String>{};

  for (final it in allItems) {
    grandIssued += it.issuedQuantity;
    grandReturned += it.returnedQuantity;
    grandPending += it.pendingQuantity;
    uniqueChallans.add(it.challanId);
  }

  return AsyncValue.data(
    PendingReturnsLedgerData(
      totalIssued: grandIssued,
      totalReturned: grandReturned,
      totalPending: grandPending,
      uniqueProductsCount: productSummaries.length,
      activeUsersCount: userSummaries.length,
      activeChallansCount: uniqueChallans.length,
      userSummaries: userSummaries,
      productSummaries: productSummaries,
      allItems: allItems,
    ),
  );
});
