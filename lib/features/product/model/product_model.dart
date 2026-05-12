import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final String weight;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.weight,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ProductModel(
      id: doc.id,
      name: data?['name'] ?? '',
      description: data?['description'] ?? '',
      price: (data?['price'] ?? 0).toDouble(),
      unit: data?['unit'] ?? '',
      imageUrl: data?['imageUrl'] ?? '',
      category: data?['category'] ?? '',
      isAvailable: data?['isAvailable'] ?? true,
      weight: data?['weight'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'weight': weight,
    };
  }
}
