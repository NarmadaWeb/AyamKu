class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String address;
  final String photoUrl;
  final String role; // 'user' or 'seller'
  final List<String> paymentMethods;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.photoUrl,
    required this.role,
    required this.paymentMethods,
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
    };
  }
}
