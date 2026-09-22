import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

/// suppliers/{supplierId} — business profile, separate from the `users/{uid}`
/// auth account that may (optionally) log in as this supplier.
@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String supplierId,
    required String name,
    String? linkedUserId,
    String? phone,
    String? address,
    required bool isActive,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}
