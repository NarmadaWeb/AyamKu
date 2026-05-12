import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final String unit;
  final String weight;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
    required this.weight,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return CartItemModel(
      id: doc.id,
      productId: data?['productId'] ?? '',
      name: data?['name'] ?? '',
      price: (data?['price'] ?? 0).toDouble(),
      imageUrl: data?['imageUrl'] ?? '',
      quantity: data?['quantity'] ?? 1,
      unit: data?['unit'] ?? '',
      weight: data?['weight'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unit': unit,
      'weight': weight,
    };
  }
}
