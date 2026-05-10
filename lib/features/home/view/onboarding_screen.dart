import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Top Image Section (60%)
              SizedBox(
                height: constraints.maxHeight * 0.6,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDtcdcEPOhRCKdGWGM9aFqAHouhKKHT2zapa97Mn_vx60vWA9-la9kCijkL_PR_JJE6Gi_B8nvy-LMZGPqR2to9_-1JuzchpttLMPRtQTlVewM_n3BXr-TnPO_OnWHQ-VmJibWUSxVsJ5rxKocC8StzovC7b3pmaAqW6emJQ8OJtxAU4KL3jbfoZdwvk8-BVoCzHrFceWoLKTM-KaWqi9mytbJPmL_ZmmsShzp6LTgEwdPh_-KyyLFz6Kca8ImxZrjEuZAJIjU4DQ',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Freshness Badge
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: AppTheme.onSecondaryContainer, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Fresh Today',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Gradient Bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.surfaceContainerLowest,
                              AppTheme.surfaceContainerLowest.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom Text and Actions Section (40%)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  transform: Matrix4.translationValues(0, -32, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Ayam Segar\nSetiap Hari',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kami menjamin ayam yang Anda terima baru dipotong pagi ini jam 05:00.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 32, height: 8, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                              const SizedBox(width: 8),
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(4))),
                              const SizedBox(width: 8),
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(4))),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 8,
                                shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                              ),
                              child: Text(
                                'Next',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
