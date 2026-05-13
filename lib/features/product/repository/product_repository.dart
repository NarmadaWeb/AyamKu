import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/product_model.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(Supabase.instance.client);
}

@riverpod
Stream<List<ProductModel>> products(Ref ref) {
  return ref.watch(productRepositoryProvider).getProducts();
}

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  Stream<List<ProductModel>> getProducts() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => ProductModel.fromJson(json)).toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _supabase.from('products').insert(product.toJson());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _supabase.from('products').update(product.toJson()).eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await _supabase.from('products').delete().eq('id', productId);
  }

  Future<String> uploadProductImage(File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'product_images/$fileName';

      await _supabase.storage.from('product_images').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _supabase.storage.from('product_images').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }
}
