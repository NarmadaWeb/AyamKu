import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/notification_model.dart';
import '../../../core/services/notification_service.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(Supabase.instance.client);
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
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  Stream<List<NotificationModel>> getUserNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('userId', user.id)
        .order('createdAt', ascending: false)
        .map((data) => data.map((json) => NotificationModel.fromJson(json)).toList());
  }

  Stream<int> getUnreadCount() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value(0);

    // Supabase stream().eq() works but might have issues with some versions or chained calls.
    // For counting unread, it's better to filter the full stream or use a different approach if eq() is failing.
    // Actually, eq() should work on SupabaseStreamBuilder if used correctly.
    // Let's try to filter the list from the stream if eq() is problematic on the builder in this version.

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('userId', user.id)
        .map((data) => data.where((json) => json['isRead'] == false).length);
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _supabase.from('notifications').insert(notification.toJson());
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase.from('notifications').update({'isRead': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('notifications')
        .update({'isRead': true})
        .eq('userId', user.id)
        .eq('isRead', false);
  }
}
