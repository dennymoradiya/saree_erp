import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/enums/audit_action.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'audit_log_entry.freezed.dart';
part 'audit_log_entry.g.dart';

/// audit_logs/{logId} — append-only. See §43. Answers "who changed what,
/// when, and why" for every sensitive mutation.
@freezed
class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String logId,
    required AuditAction action,
    required String actorId,
    required String actorRole,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String? reason,
    @TimestampConverter() required DateTime createdAt,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}
