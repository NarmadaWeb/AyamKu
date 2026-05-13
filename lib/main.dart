import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xgwmsymvvntgicuorfxf.supabase.co',
    anonKey: 'sb_publishable_YBPrrnKuMjaJNFdQqLYjMQ_k9Mhfd27',
  );

  runApp(const ProviderScope(child: AyamSegarApp()));
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
        return MaterialApp.router(
          title: 'AyamSegar',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
