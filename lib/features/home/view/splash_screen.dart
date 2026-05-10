import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLowest,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Opacity(
            opacity: 0.9,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBNY9y9u-DNl3IHtb7P2_30C3rAreN8VVmvy4Vb8BrTYzOjlhjT6BUvvFt4KTYIz8q3lgWODa4VZJaM9Vkl6CjfKHJZEUWgK4QDu2hPD6RCIaP6f0tkVTBhb-aSNSLiYI-uI7JjRWWhiSRYF2cw2nUsme8dOcv0MZBE4KPU8rdygS3W67zRW5ySHMX5erQ39fnAIVaKi3Z3n6eWfC13o_YHqB_1DiAXViVgDhwb0J0WrOvV3dGpsXze-lRyLH3iYr6pDJ9EmOnMqQ',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.multiply,
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.surfaceContainerLowest.withValues(alpha: 0.4),
                  AppTheme.surfaceContainerLowest.withValues(alpha: 0.1),
                  AppTheme.surfaceContainerLowest.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: AppTheme.primary,
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .fadeIn(duration: 500.ms)
               .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
              const SizedBox(height: 24),
              Text(
                'AyamSegar',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primary,
                  letterSpacing: -0.64,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
          // Bottom Text
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Segar dari Pemotongan, Langsung ke Dapur Anda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }
}
