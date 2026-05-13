import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/auth_repository.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isLoading = useState(false);
    final obscurePassword = useState(true);

    Future<void> handleResetPassword() async {
      if (passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password tidak boleh kosong'), backgroundColor: AppTheme.error),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak cocok'), backgroundColor: AppTheme.error),
        );
        return;
      }

      isLoading.value = true;
      try {
        await ref.read(authRepositoryProvider).updatePassword(passwordController.text);
        // Sign out to force user to login with new password
        await ref.read(authRepositoryProvider).signOut();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password berhasil diperbarui! Silakan masuk kembali.'), backgroundColor: Colors.green),
          );
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui password: $e'), backgroundColor: AppTheme.error),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat Password Baru',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan password baru Anda di bawah ini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => obscurePassword.value = !obscurePassword.value,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Password Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
