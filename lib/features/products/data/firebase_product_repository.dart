import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_repository.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Product>> watchProducts() {
    return _firestore
        .collection(FirestorePaths.products)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromJson({'productId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Stream<List<ProductSku>> watchProductSkus(String productId) {
    return _firestore
        .collection(FirestorePaths.products)
        .doc(productId)
        .collection(FirestorePaths.productSkus)
        .orderBy('sku')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductSku.fromJson({'productId': productId, ...doc.data()});
      }).toList();
    });
  }

  @override
  Future<Result<Product>> createProduct({
    required String name,
    required String productCode,
    String? description,
    bool requiresSaree = true,
    bool requiresLace = true,
    bool requiresBlouse = true,
    List<ProductSku>? initialSkus,
  }) async {
    try {
      final productRef = _firestore.collection(FirestorePaths.products).doc();
      final now = FieldValue.serverTimestamp();
      final trimmedName = name.trim();
      final trimmedCode = productCode.trim().toUpperCase();

      final batch = _firestore.batch();
      batch.set(productRef, {
        'productId': productRef.id,
        'name': trimmedName,
        'productCode': trimmedCode,
        'description': description?.trim(),
        'isActive': true,
        'requiresSaree': requiresSaree,
        'requiresLace': requiresLace,
        'requiresBlouse': requiresBlouse,
        'createdAt': now,
        'updatedAt': now,
      });

      if (initialSkus != null && initialSkus.isNotEmpty) {
        for (final sku in initialSkus) {
          final skuRef = productRef
              .collection(FirestorePaths.productSkus)
              .doc(sku.sku.trim().toUpperCase());
          batch.set(skuRef, {
            'productId': productRef.id,
            'sku': sku.sku.trim().toUpperCase(),
            'colorName': sku.colorName.trim(),
            'colorCode': sku.colorCode?.trim(),
            'isActive': true,
          });
        }
      }

      await batch.commit();

      return Success(
        Product(
          productId: productRef.id,
          name: trimmedName,
          productCode: trimmedCode,
          description: description?.trim(),
          isActive: true,
          requiresSaree: requiresSaree,
          requiresLace: requiresLace,
          requiresBlouse: requiresBlouse,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> updateProduct({
    required String productId,
    required String name,
    required String productCode,
    String? description,
    required bool requiresSaree,
    required bool requiresLace,
    required bool requiresBlouse,
  }) async {
    try {
      await _firestore.collection(FirestorePaths.products).doc(productId).update({
        'name': name.trim(),
        'productCode': productCode.trim().toUpperCase(),
        'description': description?.trim(),
        'requiresSaree': requiresSaree,
        'requiresLace': requiresLace,
        'requiresBlouse': requiresBlouse,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<ProductSku>> addProductSku({
    required String productId,
    required String sku,
    required String colorName,
    String? colorCode,
  }) async {
    try {
      final trimmedSku = sku.trim().toUpperCase();
      final trimmedColor = colorName.trim();
      final skuRef = _firestore
          .collection(FirestorePaths.products)
          .doc(productId)
          .collection(FirestorePaths.productSkus)
          .doc(trimmedSku);

      await skuRef.set({
        'productId': productId,
        'sku': trimmedSku,
        'colorName': trimmedColor,
        'colorCode': colorCode?.trim(),
        'isActive': true,
      });

      return Success(
        ProductSku(
          productId: productId,
          sku: trimmedSku,
          colorName: trimmedColor,
          colorCode: colorCode?.trim(),
          isActive: true,
        ),
      );
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> toggleProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.products)
          .doc(productId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> toggleSkuStatus({
    required String productId,
    required String sku,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.products)
          .doc(productId)
          .collection(FirestorePaths.productSkus)
          .doc(sku)
          .update({'isActive': isActive});
      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }
}
