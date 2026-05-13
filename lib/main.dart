import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/config/router.dart';
import 'core/services/notification_service.dart';
import 'features/home/repository/notification_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  await Supabase.initialize(
    url: 'https://xgwmsymvvntgicuorfxf.supabase.co',
    anonKey: 'sb_publishable_YBPrrnKuMjaJNFdQqLYjMQ_k9Mhfd27',
  );

  runApp(const ProviderScope(child: AyamSegarApp()));
}

class NotificationListenerWidget extends ConsumerWidget {
  final Widget child;
  const NotificationListenerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userNotificationsProvider, (previous, next) {
      if (next.hasValue) {
        final notifications = next.value!;
        for (var notification in notifications) {
          if (!notification.isRead &&
              notification.createdAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1)))) {
            NotificationService.showNotification(
              id: notification.id.hashCode,
              title: notification.title,
              body: notification.body,
            );
          }
        }
      }
    });
    return child;
  }
}

class AyamSegarApp extends ConsumerWidget {
  const AyamSegarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return NotificationListenerWidget(
          child: MaterialApp.router(
            title: 'AyamSegar',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
