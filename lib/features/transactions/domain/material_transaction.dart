import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/transaction_type.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'material_transaction.freezed.dart';
part 'material_transaction.g.dart';

/// material_transactions/{transactionId}
///
/// Immutable stitching-side ledger entries (issue / return / adjustment /
/// reversal). Denormalized challan balances are derived FROM these, not the
/// other way around (§34).
@freezed
class MaterialTransaction with _$MaterialTransaction {
  const factory MaterialTransaction({
    required String transactionId,
    required TransactionType type,
    required String challanId,
    required String challanItemId,
    required String stitchingUserId,
    required String productId,
    required String sku,
    required double quantity,

    /// Links a RETURN_APPROVED transaction back to its originating request.
    String? depositRequestId,
    required String createdBy,
    required String createdByRole,
    @TimestampConverter() required DateTime createdAt,
    String? notes,
  }) = _MaterialTransaction;

  factory MaterialTransaction.fromJson(Map<String, dynamic> json) =>
      _$MaterialTransactionFromJson(json);
}
