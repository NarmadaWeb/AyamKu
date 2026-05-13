class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String address;
  final String photoUrl;
  final String role; // 'user' or 'seller'
  final List<String> paymentMethods;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.photoUrl,
    required this.role,
    required this.paymentMethods,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      paymentMethods: json['paymentMethods'] is List
          ? List<String>.from((json['paymentMethods'] as List).map((e) => e.toString()))
          : [],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
      'paymentMethods': paymentMethods,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
