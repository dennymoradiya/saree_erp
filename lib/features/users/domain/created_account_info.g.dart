// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_account_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatedAccountInfoImpl _$$CreatedAccountInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatedAccountInfoImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      temporaryPassword: json['temporaryPassword'] as String,
      supplierId: json['supplierId'] as String?,
      stitchingUserId: json['stitchingUserId'] as String?,
    );

Map<String, dynamic> _$$CreatedAccountInfoImplToJson(
        _$CreatedAccountInfoImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'temporaryPassword': instance.temporaryPassword,
      'supplierId': instance.supplierId,
      'stitchingUserId': instance.stitchingUserId,
    };
