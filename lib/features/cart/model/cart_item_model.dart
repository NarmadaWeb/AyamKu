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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'] ?? '',
      weight: json['weight'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
