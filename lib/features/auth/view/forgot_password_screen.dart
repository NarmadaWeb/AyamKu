import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = useState(false);

    Future<void> handleSendResetLink() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        AppDialogs.showErrorDialog(
          context: context,
          title: 'Email Kosong',
          message: 'Silakan masukkan email Anda untuk mereset password.',
        );
        return;
      }

      isLoading.value = true;
      try {
        await ref.read(authControllerProvider.notifier).resetPassword(email);
        if (context.mounted) {
          AppDialogs.showSuccessDialog(
            context: context,
            title: 'Email Terkirim',
            message: 'Email reset password telah dikirim ke $email. Silakan periksa kotak masuk Anda.',
            onPressed: () => context.pop(),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppDialogs.showErrorDialog(
            context: context,
            title: 'Gagal',
            message: 'Gagal mengirim email reset: $e',
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: AppTheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atur Ulang Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan email Anda yang terdaftar. Kami akan mengirimkan link untuk mengatur ulang password Anda.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : handleSendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Link Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
