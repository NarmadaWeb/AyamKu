import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: doc.id,
      email: data?['email']?.toString() ?? '',
      name: data?['name']?.toString() ?? 'User',
      phoneNumber: data?['phoneNumber']?.toString() ?? '',
      address: data?['address']?.toString() ?? '',
      photoUrl: data?['photoUrl']?.toString() ?? '',
      role: data?['role']?.toString() ?? 'user',
      paymentMethods: data?['paymentMethods'] is List
          ? List<String>.from((data!['paymentMethods'] as List).map((e) => e.toString()))
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
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
