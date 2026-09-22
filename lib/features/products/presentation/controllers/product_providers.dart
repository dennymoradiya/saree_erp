import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/products/data/firebase_product_repository.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_repository.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirebaseProductRepository();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProducts();
});

final productSkusStreamProvider =
    StreamProvider.family<List<ProductSku>, String>((ref, productId) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProductSkus(productId);
});

class ProductWithSkus {
  const ProductWithSkus({
    required this.product,
    required this.skus,
  });

  final Product product;
  final List<ProductSku> skus;
}
