import 'package:saree_sutra/core/enums/allocation_type.dart';

class SupplierPendingChallanItem {
  const SupplierPendingChallanItem({
    required this.challanId,
    required this.challanItemId,
    required this.pendingQuantity,
    required this.createdAtMillis,
  });

  final String challanId;
  final String challanItemId;
  final double pendingQuantity;
  final int createdAtMillis;
}

class SupplierAllocationResult {
  const SupplierAllocationResult({
    required this.challanId,
    required this.challanItemId,
    required this.allocatedQuantity,
    this.allocationType = AllocationType.oldPendingChallan,
  });

  final String challanId;
  final String challanItemId;
  final double allocatedQuantity;
  final AllocationType allocationType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierAllocationResult &&
          runtimeType == other.runtimeType &&
          challanId == other.challanId &&
          challanItemId == other.challanItemId &&
          allocatedQuantity == other.allocatedQuantity &&
          allocationType == other.allocationType;

  @override
  int get hashCode => Object.hash(
        challanId,
        challanItemId,
        allocatedQuantity,
        allocationType,
      );

  @override
  String toString() =>
      'SupplierAllocationResult(challanId: $challanId, challanItemId: $challanItemId, allocatedQuantity: $allocatedQuantity, type: $allocationType)';
}

class SupplierFifoCalculation {
  const SupplierFifoCalculation({
    required this.allocations,
    required this.remainingForNewChallan,
  });

  final List<SupplierAllocationResult> allocations;
  final double remainingForNewChallan;
}

/// ENGINE B: SupplierMaterialLedger — FIFO allocation for ONE material type.
///
/// Scope: supplierId + productId + sku + materialType.
SupplierFifoCalculation allocateSupplierMaterialFIFO({
  required List<SupplierPendingChallanItem> pendingItems,
  required double suppliedQuantity,
}) {
  if (suppliedQuantity < 0) {
    throw ArgumentError('Supplied quantity cannot be negative.');
  }

  final sorted = pendingItems
      .where((item) => item.pendingQuantity > 0)
      .toList()
    ..sort((a, b) => a.createdAtMillis.compareTo(b.createdAtMillis));

  var remaining = suppliedQuantity;
  final allocations = <SupplierAllocationResult>[];

  for (final item in sorted) {
    if (remaining <= 0) break;
    final allocated =
        item.pendingQuantity < remaining ? item.pendingQuantity : remaining;
    if (allocated <= 0) continue;

    allocations.add(
      SupplierAllocationResult(
        challanId: item.challanId,
        challanItemId: item.challanItemId,
        allocatedQuantity: allocated,
        allocationType: AllocationType.oldPendingChallan,
      ),
    );
    remaining -= allocated;
  }

  return SupplierFifoCalculation(
    allocations: allocations,
    remainingForNewChallan: remaining,
  );
}
