import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/home/view/splash_screen.dart';
import '../../features/home/view/onboarding_screen.dart';
import '../../features/product/view/catalog_screen.dart';
import '../../features/product/view/product_detail_screen.dart';
import '../../features/cart/view/cart_screen.dart';
import '../../features/cart/view/checkout_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/orders/view/orders_screen.dart';
import '../../features/seller/view/seller_dashboard_screen.dart';
import '../../features/loyalty/view/loyalty_screen.dart';
import '../../features/help/view/help_center_screen.dart';
import '../../features/recipes/view/recipes_screen.dart';
import '../../features/auth/controller/auth_controller.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => const ProductDetailScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/seller-dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/loyalty',
        builder: (context, state) => const LoyaltyScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipesScreen(),
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/onboarding' || state.matchedLocation == '/splash';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/';
      return null;
    },
  );
}
