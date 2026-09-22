import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/material_type.dart';

/// Single distribution line item showing which challan, supplier, product,
/// and material quantity were fulfilled in a delivery event.
class SupplierDistributionItem {
  const SupplierDistributionItem({
    required this.transactionId,
    required this.deliveryBatchId,
    required this.challanId,
    required this.challanNumber,
    required this.supplierId,
    required this.supplierName,
    required this.productId,
    required this.productName,
    required this.sku,
    this.colorName,
    required this.materialType,
    required this.quantity,
    required this.allocationType,
    required this.timestamp,
    this.notes,
  });

  final String transactionId;
  final String deliveryBatchId;
  final String challanId;
  final String challanNumber;
  final String supplierId;
  final String supplierName;
  final String productId;
  final String productName;
  final String sku;
  final String? colorName;
  final MaterialType materialType;
  final double quantity;
  final AllocationType allocationType;
  final DateTime timestamp;
  final String? notes;
}

/// Day-wise aggregation of supplier material deliveries.
class DayWiseSupplierLedger {
  const DayWiseSupplierLedger({
    required this.date,
    required this.totalSaree,
    required this.totalLace,
    required this.totalBlouse,
    required this.totalTransactions,
    required this.distributions,
  });

  final DateTime date;
  final double totalSaree;
  final double totalLace;
  final double totalBlouse;
  final int totalTransactions;
  final List<SupplierDistributionItem> distributions;

  double get totalPieces => totalSaree + totalLace + totalBlouse;

  int get uniqueChallansCount =>
      distributions.map((d) => d.challanId).toSet().length;

  int get uniqueSuppliersCount =>
      distributions.map((d) => d.supplierId).toSet().length;
}
