import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String status; // 'Menunggu Konfirmasi', 'Dalam Proses Packing', 'Dalam Pengiriman', 'Selesai', 'Dibatalkan'
  final double totalPrice;
  final List<dynamic> items;
  final DateTime createdAt;
  final String deliveryTimeSlot;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.status,
    required this.totalPrice,
    required this.items,
    required this.createdAt,
    required this.deliveryTimeSlot,
    required this.paymentMethod,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return OrderModel(
      id: doc.id,
      userId: data?['userId'] ?? '',
      userName: data?['userName'] ?? '',
      userPhone: data?['userPhone'] ?? '',
      userAddress: data?['userAddress'] ?? '',
      status: data?['status'] ?? 'Menunggu Konfirmasi',
      totalPrice: (data?['totalPrice'] ?? 0).toDouble(),
      items: data?['items'] ?? [],
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryTimeSlot: data?['deliveryTimeSlot'] ?? '',
      paymentMethod: data?['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'status': status,
      'totalPrice': totalPrice,
      'items': items,
      'createdAt': FieldValue.serverTimestamp(),
      'deliveryTimeSlot': deliveryTimeSlot,
      'paymentMethod': paymentMethod,
    };
  }
}
