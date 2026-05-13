import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/order.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) {
  return OrderRepository(Supabase.instance.client);
}

@riverpod
Stream<List<OrderModel>> userOrders(Ref ref) {
  return ref.watch(orderRepositoryProvider).getUserOrders();
}

@riverpod
Stream<List<OrderModel>> allOrders(Ref ref) {
  return ref.watch(orderRepositoryProvider).getAllOrders();
}

class OrderRepository {
  final SupabaseClient _supabase;

  OrderRepository(this._supabase);

  Stream<List<OrderModel>> getUserOrders() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('userId', user.id)
        .order('createdAt', ascending: false)
        .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: false)
        .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }

  Future<void> createOrder(OrderModel order) async {
    await _supabase.from('orders').insert(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _supabase.from('orders').update({'status': status}).eq('id', orderId);

    // Fetch order details for notification
    final orderData = await _supabase.from('orders').select().eq('id', orderId).single();
    final order = OrderModel.fromJson(orderData);

    await _supabase.from('notifications').insert({
      'userId': order.userId,
      'title': 'Update Pesanan',
      'body': 'Status pesanan ${order.id.substring(0, 8)} Anda sekarang: $status',
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': false,
      'type': 'order_status',
      'relatedId': order.id,
    });
  }
}
