import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/cart_item_model.dart';

part 'cart_repository.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(Supabase.instance.client);
}

@riverpod
Stream<List<CartItemModel>> cartItems(Ref ref) {
  return ref.watch(cartRepositoryProvider).getCartItems();
}

class CartRepository {
  final SupabaseClient _supabase;

  CartRepository(this._supabase);

  String? get _uid => _supabase.auth.currentUser?.id;

  Stream<List<CartItemModel>> getCartItems() {
    if (_uid == null) return Stream.value([]);
    return _supabase
        .from('cart')
        .stream(primaryKey: ['id'])
        .eq('userId', _uid!)
        .map((data) => data.map((json) => CartItemModel.fromJson(json)).toList());
  }

  Future<void> addToCart(CartItemModel item) async {
    if (_uid == null) return;

    // Check stock first
    final productData = await _supabase.from('products').select('stock').eq('id', item.productId).single();
    final stock = productData['stock'] as int;

    final existingItem = await _supabase
        .from('cart')
        .select()
        .eq('userId', _uid!)
        .eq('productId', item.productId)
        .maybeSingle();

    if (existingItem != null) {
      final existingQty = existingItem['quantity'] as int;
      final newQty = existingQty + item.quantity;

      if (newQty > stock) {
        throw Exception('Stok tidak mencukupi');
      }

      await _supabase
          .from('cart')
          .update({'quantity': newQty})
          .eq('id', existingItem['id']);
    } else {
      if (item.quantity > stock) {
        throw Exception('Stok tidak mencukupi');
      }
      final json = item.toJson();
      json['userId'] = _uid;
      await _supabase.from('cart').insert(json);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_uid == null) return;
    if (quantity <= 0) {
      await removeFromCart(itemId);
    } else {
      // Check stock
      final cartData = await _supabase.from('cart').select('productId').eq('id', itemId).single();
      final productId = cartData['productId'];

      final productData = await _supabase.from('products').select('stock').eq('id', productId).single();
      final stock = productData['stock'] as int;

      if (quantity > stock) {
        throw Exception('Stok tidak mencukupi');
      }

      await _supabase
          .from('cart')
          .update({'quantity': quantity})
          .eq('id', itemId);
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (_uid == null) return;
    await _supabase
        .from('cart')
        .delete()
        .eq('id', itemId);
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    await _supabase
        .from('cart')
        .delete()
        .eq('userId', _uid!);
  }
}
