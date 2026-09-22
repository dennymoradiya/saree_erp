import 'package:flutter/material.dart';

/// Status colors used consistently across the app for challan / pending /
/// request states (§53 — never mix Supplier Pending and Stitching Pending
/// visual language).
abstract class AppColors {
  static const Color primarySeed = Color(0xFF5B3A9B); // saree-purple brand seed

  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusPartial = Color(0xFFF9A825);
  static const Color statusPending = Color(0xFFEF6C00);
  static const Color statusRejected = Color(0xFFC62828);
  static const Color statusCancelled = Color(0xFF616161);
  static const Color statusDraft = Color(0xFF9E9E9E);

  /// Stitching-side pending (finished-saree production).
  static const Color stitchingPending = Color(0xFF1565C0);
  /// Supplier-side pending (raw-material shortage).
  static const Color supplierPending = Color(0xFFAD1457);
}
