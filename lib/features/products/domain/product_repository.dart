import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';

abstract interface class ProductRepository {
  Stream<List<Product>> watchProducts();

  Stream<List<ProductSku>> watchProductSkus(String productId);

  Future<Result<Product>> createProduct({
    required String name,
    required String productCode,
    String? description,
    bool requiresSaree = true,
    bool requiresLace = true,
    bool requiresBlouse = true,
    List<ProductSku>? initialSkus,
  });

  Future<Result<void>> updateProduct({
    required String productId,
    required String name,
    required String productCode,
    String? description,
    required bool requiresSaree,
    required bool requiresLace,
    required bool requiresBlouse,
  });

  Future<Result<ProductSku>> addProductSku({
    required String productId,
    required String sku,
    required String colorName,
    String? colorCode,
  });

  Future<Result<void>> toggleProductStatus({
    required String productId,
    required bool isActive,
  });

  Future<Result<void>> toggleSkuStatus({
    required String productId,
    required String sku,
    required bool isActive,
  });
}
