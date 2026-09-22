// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      notificationId: json['notificationId'] as String,
      recipientUserId: json['recipientUserId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      eventType: json['eventType'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      idempotencyKey: json['idempotencyKey'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'recipientUserId': instance.recipientUserId,
      'title': instance.title,
      'body': instance.body,
      'eventType': instance.eventType,
      'data': instance.data,
      'isRead': instance.isRead,
      'idempotencyKey': instance.idempotencyKey,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
