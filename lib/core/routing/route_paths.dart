abstract class RoutePaths {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  static const String adminDashboard = '/admin';
  static const String adminSuppliers = '/admin/suppliers';
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminChallans = '/admin/challans';
  static const String adminCreateChallan = '/admin/challans/create';
  static const String adminChallanDetail = '/admin/challans/:id';
  static const String adminDepositRequests = '/admin/deposit-requests';
  static const String adminSupplierLedger = '/admin/supplier-ledger';
  static const String adminStitchingLedger = '/admin/stitching-ledger';

  static const String stitchingDashboard = '/stitching';
  static const String stitchingChallans = '/stitching/challans';
  static const String stitchingCreateDepositRequest = '/stitching/deposit-requests/create';
  static const String stitchingLedger = '/stitching/ledger';

  static const String supplierDashboard = '/supplier';
  static const String supplierChallans = '/supplier/challans';
  static const String supplierCreateChallan = '/supplier/challans/create';
  static const String supplierLedger = '/supplier/ledger';
}

