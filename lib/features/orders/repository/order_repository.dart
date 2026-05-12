import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/order.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) {
  return OrderRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
}

@riverpod
Stream<List<OrderModel>> userOrders(Ref ref) {
  return ref.watch(orderRepositoryProvider).getUserOrders();
}

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRepository(this._firestore, this._auth);

  Stream<List<OrderModel>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').add(order.toFirestore());
  }
}
