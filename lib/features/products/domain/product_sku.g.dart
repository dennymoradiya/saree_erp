// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_sku.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductSkuImpl _$$ProductSkuImplFromJson(Map<String, dynamic> json) =>
    _$ProductSkuImpl(
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      colorName: json['colorName'] as String,
      colorCode: json['colorCode'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$ProductSkuImplToJson(_$ProductSkuImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'sku': instance.sku,
      'colorName': instance.colorName,
      'colorCode': instance.colorCode,
      'isActive': instance.isActive,
    };
