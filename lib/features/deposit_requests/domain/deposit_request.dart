import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'deposit_request.freezed.dart';
part 'deposit_request.g.dart';

/// A single product/SKU line within a deposit request (§39).
@freezed
class DepositRequestItem with _$DepositRequestItem {
  const factory DepositRequestItem({
    required String productId,
    required String sku,
    required double requestedQuantity,
  }) = _DepositRequestItem;

  factory DepositRequestItem.fromJson(Map<String, dynamic> json) =>
      _$DepositRequestItemFromJson(json);
}

/// deposit_requests/{requestId}
///
/// Submitting a request must NOT change any official challan balance.
/// Only an admin APPROVE action (executed server-side, running the
/// stitching FIFO engine) creates official RETURN transactions (§15, §16).
/// Once approved, the request document becomes immutable.
@freezed
class DepositRequest with _$DepositRequest {
  const factory DepositRequest({
    required String requestId,
    required String stitchingUserId,
    required DepositRequestStatus status,
    required List<DepositRequestItem> items,
    String? notes,
    @TimestampConverter() required DateTime submittedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,

    /// Populated only after APPROVED — the FIFO allocation result, for
    /// full traceability of which challans absorbed the return.
    List<String>? resultingTransactionIds,
  }) = _DepositRequest;

  factory DepositRequest.fromJson(Map<String, dynamic> json) =>
      _$DepositRequestFromJson(json);
}
