/// Central registry of Firestore top-level collection names.
///
/// Never hardcode collection name strings elsewhere — always reference
/// this file so a rename is a one-place change.
abstract class FirestorePaths {
  static const String users = 'users';
  static const String products = 'products';
  // Sub-collection name under products/{productId}/skus/{skuId}
  static const String productSkus = 'skus';

  static const String suppliers = 'suppliers';
  static const String stitchingUsers = 'stitching_users';

  static const String challans = 'challans';
  static const String challanItems = 'challan_items';

  static const String depositRequests = 'deposit_requests';

  static const String materialTransactions = 'material_transactions';
  static const String supplierMaterialTransactions =
      'supplier_material_transactions';

  static const String notifications = 'notifications';
  static const String auditLogs = 'audit_logs';

  // Atomic counters (e.g. challan number sequence) live here.
  static const String counters = 'counters';
  static const String challanNumberCounter = 'challan_number';
}
