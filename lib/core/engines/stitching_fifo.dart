/// Input representation for a pending stitching challan item eligible for FIFO return.
class StitchingPendingChallanItem {
  const StitchingPendingChallanItem({
    required this.challanId,
    required this.challanItemId,
    required this.sareePendingQuantity,
    required this.createdAtMillis,
  });

  final String challanId;
  final String challanItemId;
  final double sareePendingQuantity;
  final int createdAtMillis;
}

/// Output allocation against an individual challan item.
class StitchingAllocationResult {
  const StitchingAllocationResult({
    required this.challanId,
    required this.challanItemId,
    required this.allocatedQuantity,
  });

  final String challanId;
  final String challanItemId;
  final double allocatedQuantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StitchingAllocationResult &&
          runtimeType == other.runtimeType &&
          challanId == other.challanId &&
          challanItemId == other.challanItemId &&
          allocatedQuantity == other.allocatedQuantity;

  @override
  int get hashCode => Object.hash(challanId, challanItemId, allocatedQuantity);

  @override
  String toString() =>
      'StitchingAllocationResult(challanId: $challanId, challanItemId: $challanItemId, allocatedQuantity: $allocatedQuantity)';
}

/// ENGINE A: StitchingProductionLedger — FIFO allocation.
///
/// Scope: stitchingUserId + productId + sku. The caller is
/// responsible for fetching ONLY the challan_items that match that exact
/// scope and are not CANCELLED before calling this pure function.
///
/// Rules:
///  - Oldest pending challan (by createdAtMillis) is settled first.
///  - A returned quantity that exceeds total eligible pending across the
///    scope is REJECTED as a whole — never partially applied, never allowed
///    to create a negative pending balance.
List<StitchingAllocationResult> allocateStitchingReturnFIFO({
  required List<StitchingPendingChallanItem> pendingItems,
  required double returnedFinishedQuantity,
}) {
  if (returnedFinishedQuantity <= 0) {
    throw ArgumentError('Returned quantity must be greater than zero.');
  }

  final sorted = pendingItems
      .where((item) => item.sareePendingQuantity > 0)
      .toList()
    ..sort((a, b) => a.createdAtMillis.compareTo(b.createdAtMillis));

  final totalEligible = sorted.fold<double>(
    0.0,
    (sum, item) => sum + item.sareePendingQuantity,
  );

  if (returnedFinishedQuantity > totalEligible) {
    throw StateError(
      'User has only $totalEligible pending sarees available for return, '
      'but $returnedFinishedQuantity were entered.',
    );
  }

  var remaining = returnedFinishedQuantity;
  final results = <StitchingAllocationResult>[];

  for (final item in sorted) {
    if (remaining <= 0) break;
    final allocated =
        item.sareePendingQuantity < remaining ? item.sareePendingQuantity : remaining;
    if (allocated <= 0) continue;
    results.add(
      StitchingAllocationResult(
        challanId: item.challanId,
        challanItemId: item.challanItemId,
        allocatedQuantity: allocated,
      ),
    );
    remaining -= allocated;
  }

  return results;
}
