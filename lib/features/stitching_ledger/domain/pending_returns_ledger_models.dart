/// Represents a single challan item line that still has finished sarees pending return.
class PendingReturnChallanItem {
  const PendingReturnChallanItem({
    required this.challanItemId,
    required this.challanId,
    required this.challanNumber,
    required this.issuedAt,
    required this.stitchingUserId,
    required this.stitchingUserName,
    required this.productId,
    required this.sku,
    required this.productName,
    this.color,
    required this.issuedQuantity,
    required this.returnedQuantity,
    required this.pendingQuantity,
  });

  final String challanItemId;
  final String challanId;
  final String challanNumber;
  final DateTime issuedAt;
  final String stitchingUserId;
  final String stitchingUserName;
  final String productId;
  final String sku;
  final String productName;
  final String? color;
  final double issuedQuantity;
  final double returnedQuantity;
  final double pendingQuantity;
}

/// Aggregated pending returns grouped by product and SKU variant.
class ProductPendingReturn {
  ProductPendingReturn({
    required this.productId,
    required this.sku,
    required this.productName,
    this.color,
    required this.totalIssued,
    required this.totalReturned,
    required this.totalPending,
    required this.items,
    required this.userPendingMap,
  });

  final String productId;
  final String sku;
  final String productName;
  final String? color;
  final double totalIssued;
  final double totalReturned;
  final double totalPending;
  final List<PendingReturnChallanItem> items;

  /// Map of stitchingUserId -> pending quantity for this product (used for Admin user-wise breakdown)
  final Map<String, double> userPendingMap;
}

/// Aggregated pending returns grouped by stitching unit / user (User-wise pending products).
class UserPendingReturn {
  UserPendingReturn({
    required this.stitchingUserId,
    required this.userName,
    this.userPhone,
    required this.totalIssued,
    required this.totalReturned,
    required this.totalPending,
    required this.products,
    required this.items,
  });

  final String stitchingUserId;
  final String userName;
  final String? userPhone;
  final double totalIssued;
  final double totalReturned;
  final double totalPending;
  final List<ProductPendingReturn> products;
  final List<PendingReturnChallanItem> items;
}

/// Root data object holding all aggregates for the Pending Returns Ledger.
class PendingReturnsLedgerData {
  const PendingReturnsLedgerData({
    required this.totalIssued,
    required this.totalReturned,
    required this.totalPending,
    required this.uniqueProductsCount,
    required this.activeUsersCount,
    required this.activeChallansCount,
    required this.userSummaries,
    required this.productSummaries,
    required this.allItems,
  });

  final double totalIssued;
  final double totalReturned;
  final double totalPending;
  final int uniqueProductsCount;
  final int activeUsersCount;
  final int activeChallansCount;
  final List<UserPendingReturn> userSummaries;
  final List<ProductPendingReturn> productSummaries;
  final List<PendingReturnChallanItem> allItems;
}
