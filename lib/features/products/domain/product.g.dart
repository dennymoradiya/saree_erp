// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      productId: json['productId'] as String,
      name: json['name'] as String,
      productCode: json['productCode'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      requiresSaree: json['requiresSaree'] as bool? ?? true,
      requiresLace: json['requiresLace'] as bool? ?? true,
      requiresBlouse: json['requiresBlouse'] as bool? ?? true,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'productCode': instance.productCode,
      'description': instance.description,
      'isActive': instance.isActive,
      'requiresSaree': instance.requiresSaree,
      'requiresLace': instance.requiresLace,
      'requiresBlouse': instance.requiresBlouse,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
