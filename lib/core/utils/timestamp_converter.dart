import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts a Firestore [Timestamp] (or a raw millisecond int, or an already
/// materialized [DateTime]) into a [DateTime], and serializes a [DateTime]
/// back to a [Timestamp] for writes.
///
/// Use this converter on every `DateTime` field in a `@freezed` model that is
/// persisted to Firestore (createdAt, updatedAt, issuedAt, submittedAt, ...).
/// Never store dates as formatted strings (see docs/ARCHITECTURE.md §51).
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw FormatException('Cannot convert $json (${json.runtimeType}) to DateTime');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

/// Nullable variant, for optional timestamp fields such as `reviewedAt`.
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    return const TimestampConverter().fromJson(json);
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return const TimestampConverter().toJson(object);
  }
}
