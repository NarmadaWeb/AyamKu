import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/cart_item_model.dart';

part 'cart_repository.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
}

@riverpod
Stream<List<CartItemModel>> cartItems(Ref ref) {
  return ref.watch(cartRepositoryProvider).getCartItems();
}

class CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepository(this._firestore, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<CartItemModel>> getCartItems() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CartItemModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addToCart(CartItemModel item) async {
    if (_uid == null) return;

    final cartRef = _firestore.collection('users').doc(_uid).collection('cart');
    final existingItems = await cartRef.where('productId', isEqualTo: item.productId).get();

    if (existingItems.docs.isNotEmpty) {
      final docId = existingItems.docs.first.id;
      final existingQty = existingItems.docs.first.data()['quantity'] as int;
      await cartRef.doc(docId).update({'quantity': existingQty + item.quantity});
    } else {
      await cartRef.add(item.toFirestore());
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_uid == null) return;
    if (quantity <= 0) {
      await removeFromCart(itemId);
    } else {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('cart')
          .doc(itemId)
          .update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    final cartRef = _firestore.collection('users').doc(_uid).collection('cart');
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
