// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stitching_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StitchingUserProfileImpl _$$StitchingUserProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$StitchingUserProfileImpl(
      stitchingUserId: json['stitchingUserId'] as String,
      name: json['name'] as String,
      linkedUserId: json['linkedUserId'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$StitchingUserProfileImplToJson(
        _$StitchingUserProfileImpl instance) =>
    <String, dynamic>{
      'stitchingUserId': instance.stitchingUserId,
      'name': instance.name,
      'linkedUserId': instance.linkedUserId,
      'phone': instance.phone,
      'address': instance.address,
      'isActive': instance.isActive,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
