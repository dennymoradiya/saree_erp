import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'challan.freezed.dart';
part 'challan.g.dart';

ChallanStatus _statusFromJson(dynamic val) => ChallanStatus.fromValue(val);
String _statusToJson(ChallanStatus status) => status.value;

/// challans/{challanId} — the header. Line items live in the separate
/// `challan_items` collection (see [ChallanItem]) so a challan can carry
/// multiple products/SKUs (docs/ARCHITECTURE.md §4).
@freezed
class Challan with _$Challan {
  const factory Challan({
    required String challanId,

    /// Human-readable sequence number, e.g. CH-2026-000001. Never the
    /// Firestore document id (§50).
    required String challanNumber,
    required String supplierId,
    required String stitchingUserId,
    required String createdBy,
    required String createdByRole,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required ChallanStatus status,
    @TimestampConverter() required DateTime issuedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? notes,
    String? cancelledReason,
    String? cancelledBy,
    @NullableTimestampConverter() DateTime? cancelledAt,
  }) = _Challan;

  factory Challan.fromJson(Map<String, dynamic> json) =>
      _$ChallanFromJson(json);
}
