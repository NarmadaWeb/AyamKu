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
  final String? paymentProofUrl;
  final String paymentStatus; // 'pending', 'success', 'failed'
  final String? snapToken;
  final String? midtransOrderId;

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
    this.paymentProofUrl,
    this.paymentStatus = 'pending',
    this.snapToken,
    this.midtransOrderId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userAddress: json['userAddress'] ?? '',
      status: json['status'] ?? 'Menunggu Konfirmasi',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      items: json['items'] ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      deliveryTimeSlot: json['deliveryTimeSlot'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentProofUrl: json['paymentProofUrl'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      snapToken: json['snapToken'],
      midtransOrderId: json['midtransOrderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'status': status,
      'totalPrice': totalPrice,
      'items': items,
      'createdAt': createdAt.toIso8601String(),
      'deliveryTimeSlot': deliveryTimeSlot,
      'paymentMethod': paymentMethod,
      'paymentProofUrl': paymentProofUrl,
      'paymentStatus': paymentStatus,
      'snapToken': snapToken,
      'midtransOrderId': midtransOrderId,
    };
  }
}
