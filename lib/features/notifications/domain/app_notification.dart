import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saree_sutra/core/utils/timestamp_converter.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// notifications/{notificationId}
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String notificationId,
    required String recipientUserId,
    required String title,
    required String body,
    required String eventType,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,

    /// Prevents duplicate pushes for the same underlying event (§46).
    required String idempotencyKey,
    @TimestampConverter() required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
