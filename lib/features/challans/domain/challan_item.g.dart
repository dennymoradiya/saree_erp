// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challan_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallanItemImpl _$$ChallanItemImplFromJson(Map<String, dynamic> json) =>
    _$ChallanItemImpl(
      challanItemId: json['challanItemId'] as String,
      challanId: json['challanId'] as String,
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      productNameSnapshot: json['productNameSnapshot'] as String,
      skuSnapshot: json['skuSnapshot'] as String,
      colorNameSnapshot: json['colorNameSnapshot'] as String?,
      sareeIssuedQuantity: (json['sareeIssuedQuantity'] as num).toDouble(),
      sareeReturnedQuantity: (json['sareeReturnedQuantity'] as num).toDouble(),
      sareePendingQuantity: (json['sareePendingQuantity'] as num).toDouble(),
      laceRequiredQuantity: (json['laceRequiredQuantity'] as num).toDouble(),
      laceSuppliedQuantity: (json['laceSuppliedQuantity'] as num).toDouble(),
      lacePendingSupplierQuantity:
          (json['lacePendingSupplierQuantity'] as num).toDouble(),
      blouseRequiredQuantity:
          (json['blouseRequiredQuantity'] as num).toDouble(),
      blouseSuppliedQuantity:
          (json['blouseSuppliedQuantity'] as num).toDouble(),
      blousePendingSupplierQuantity:
          (json['blousePendingSupplierQuantity'] as num).toDouble(),
      sareeRequiredQuantity: (json['sareeRequiredQuantity'] as num).toDouble(),
      sareeSuppliedQuantity: (json['sareeSuppliedQuantity'] as num).toDouble(),
      sareePendingSupplierQuantity:
          (json['sareePendingSupplierQuantity'] as num).toDouble(),
      stitchingReturnedQuantity:
          (json['stitchingReturnedQuantity'] as num?)?.toDouble() ?? 0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ChallanItemImplToJson(_$ChallanItemImpl instance) =>
    <String, dynamic>{
      'challanItemId': instance.challanItemId,
      'challanId': instance.challanId,
      'productId': instance.productId,
      'sku': instance.sku,
      'productNameSnapshot': instance.productNameSnapshot,
      'skuSnapshot': instance.skuSnapshot,
      'colorNameSnapshot': instance.colorNameSnapshot,
      'sareeIssuedQuantity': instance.sareeIssuedQuantity,
      'sareeReturnedQuantity': instance.sareeReturnedQuantity,
      'sareePendingQuantity': instance.sareePendingQuantity,
      'laceRequiredQuantity': instance.laceRequiredQuantity,
      'laceSuppliedQuantity': instance.laceSuppliedQuantity,
      'lacePendingSupplierQuantity': instance.lacePendingSupplierQuantity,
      'blouseRequiredQuantity': instance.blouseRequiredQuantity,
      'blouseSuppliedQuantity': instance.blouseSuppliedQuantity,
      'blousePendingSupplierQuantity': instance.blousePendingSupplierQuantity,
      'sareeRequiredQuantity': instance.sareeRequiredQuantity,
      'sareeSuppliedQuantity': instance.sareeSuppliedQuantity,
      'sareePendingSupplierQuantity': instance.sareePendingSupplierQuantity,
      'stitchingReturnedQuantity': instance.stitchingReturnedQuantity,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
