import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/product_model.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<ProductModel>> products(Ref ref) {
  return ref.watch(productRepositoryProvider).getProducts();
}

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  Future<String> uploadProductImage(File file) async {
    try {
      // Save locally instead of Firebase Storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
      final localFile = File(p.join(appDir.path, fileName));
      await file.copy(localFile.path);
      return localFile.path;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
