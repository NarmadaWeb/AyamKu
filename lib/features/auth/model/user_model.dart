import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String address;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.photoUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: doc.id,
      email: data?['email'] ?? '',
      name: data?['name'] ?? 'User',
      phoneNumber: data?['phoneNumber'] ?? '',
      address: data?['address'] ?? '',
      photoUrl: data?['photoUrl'] ?? '',
    );
  }
}
