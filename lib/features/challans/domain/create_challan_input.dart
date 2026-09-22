class CreateChallanItemInput {
  const CreateChallanItemInput({
    required this.productId,
    required this.sku,
    required this.productNameSnapshot,
    required this.skuSnapshot,
    this.colorNameSnapshot,
    this.requiresSaree = true,
    this.requiresLace = true,
    this.requiresBlouse = true,
    required this.sareeIssuedQuantity,
    required this.sareeSuppliedQuantity,
    required this.laceSuppliedQuantity,
    required this.blouseSuppliedQuantity,
  });

  final String productId;
  final String sku;
  final String productNameSnapshot;
  final String skuSnapshot;
  final String? colorNameSnapshot;

  final bool requiresSaree;
  final bool requiresLace;
  final bool requiresBlouse;

  final double sareeIssuedQuantity;
  final double sareeSuppliedQuantity;
  final double laceSuppliedQuantity;
  final double blouseSuppliedQuantity;

  double get sareeRequired => requiresSaree ? sareeIssuedQuantity : 0.0;
  double get laceRequired => requiresLace ? sareeIssuedQuantity : 0.0;
  double get blouseRequired => requiresBlouse ? sareeIssuedQuantity : 0.0;

  double get sareeShortage =>
      (sareeRequired - sareeSuppliedQuantity).clamp(0.0, double.infinity);
  double get laceShortage =>
      (laceRequired - laceSuppliedQuantity).clamp(0.0, double.infinity);
  double get blouseShortage =>
      (blouseRequired - blouseSuppliedQuantity).clamp(0.0, double.infinity);

  bool get hasShortage =>
      sareeShortage > 0 || laceShortage > 0 || blouseShortage > 0;
}

class CreateChallanInput {
  const CreateChallanInput({
    required this.supplierId,
    required this.stitchingUserId,
    required this.items,
    this.notes,
    this.creatorRole = 'admin',
  });

  final String supplierId;
  final String stitchingUserId;
  final List<CreateChallanItemInput> items;
  final String? notes;
  final String creatorRole;
}
