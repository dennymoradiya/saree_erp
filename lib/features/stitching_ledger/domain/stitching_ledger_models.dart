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
