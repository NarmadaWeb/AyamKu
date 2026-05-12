import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? type; // e.g., 'order_status'
  final String? relatedId; // e.g., orderId

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.type,
    this.relatedId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return NotificationModel(
      id: doc.id,
      userId: data?['userId'] ?? '',
      title: data?['title'] ?? '',
      body: data?['body'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data?['isRead'] ?? false,
      type: data?['type'],
      relatedId: data?['relatedId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'type': type,
      'relatedId': relatedId,
    };
  }
}
