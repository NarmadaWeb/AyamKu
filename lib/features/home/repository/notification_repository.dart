import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/notification_model.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
}

@riverpod
Stream<List<NotificationModel>> userNotifications(Ref ref) {
  return ref.watch(notificationRepositoryProvider).getUserNotifications();
}

@riverpod
Stream<int> unreadNotificationsCount(Ref ref) {
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
}

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository(this._firestore, this._auth);

  Stream<List<NotificationModel>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').add(notification.toFirestore());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final unread = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
