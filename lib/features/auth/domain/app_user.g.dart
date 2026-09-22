// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _roleFromJson(json['role']),
      isActive: json['isActive'] as bool,
      phone: json['phone'] as String?,
      supplierId: json['supplierId'] as String?,
      stitchingUserId: json['stitchingUserId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'role': _roleToJson(instance.role),
      'isActive': instance.isActive,
      'phone': instance.phone,
      'supplierId': instance.supplierId,
      'stitchingUserId': instance.stitchingUserId,
      'fcmToken': instance.fcmToken,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
