import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/notification_repository.dart';
import '../model/notification_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationRepositoryProvider).markAllAsRead(),
            child: const Text('Tandai semua dibaca'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.outline),
                  SizedBox(height: 16),
                  Text('Belum ada notifikasi'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(context, ref, notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, NotificationModel notification) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notification.isRead ? AppTheme.surfaceContainerHigh : AppTheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIcon(notification.type),
          color: notification.isRead ? AppTheme.onSurfaceVariant : AppTheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          color: notification.isRead ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
        // Logic to navigate based on type can be added here
      },
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'order_status':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
