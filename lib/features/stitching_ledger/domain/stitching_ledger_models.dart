/// Single distribution line item showing which challan received how many
/// finished sarees returned by a stitching unit.
class StitchingDistributionItem {
  const StitchingDistributionItem({
    required this.transactionId,
    required this.challanId,
    required this.challanNumber,
    required this.stitchingUserId,
    required this.stitchingUserName,
    required this.productId,
    required this.productName,
    required this.sku,
    this.colorName,
    required this.quantity,
    required this.timestamp,
    this.depositRequestId,
    this.notes,
  });

  final String transactionId;
  final String challanId;
  final String challanNumber;
  final String stitchingUserId;
  final String stitchingUserName;
  final String productId;
  final String productName;
  final String sku;
  final String? colorName;
  final double quantity;
  final DateTime timestamp;
  final String? depositRequestId;
  final String? notes;
}

/// Day-wise aggregation of stitching production returns.
class DayWiseStitchingLedger {
  const DayWiseStitchingLedger({
    required this.date,
    required this.totalReturnedQuantity,
    required this.totalEvents,
    required this.distributions,
  });

  final DateTime date;
  final double totalReturnedQuantity;
  final int totalEvents;
  final List<StitchingDistributionItem> distributions;

  int get uniqueChallansCount =>
      distributions.map((d) => d.challanId).toSet().length;

  int get uniqueStitchingUsersCount =>
      distributions.map((d) => d.stitchingUserId).toSet().length;
}

typedef ProductionReturnTotal = ({
  String productId,
  String productName,
  String sku,
  double quantity,
});

/// Totals the return allocations by product variant across the filtered days.
List<ProductionReturnTotal> summarizeProductionReturns(
  Iterable<DayWiseStitchingLedger> days,
) {
  final totals = <(String, String), ProductionReturnTotal>{};
  for (final day in days) {
    for (final item in day.distributions) {
      final key = (item.productId, item.sku);
      totals[key] = (
        productId: item.productId,
        productName: item.productName,
        sku: item.sku,
        quantity: (totals[key]?.quantity ?? 0) + item.quantity,
      );
    }
  }

  return totals.values.toList()
    ..sort((a, b) {
      final nameOrder = a.productName.compareTo(b.productName);
      if (nameOrder != 0) return nameOrder;
      final skuOrder = a.sku.compareTo(b.sku);
      return skuOrder == 0 ? a.productId.compareTo(b.productId) : skuOrder;
    });
}
