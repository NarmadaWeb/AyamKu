import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class SellerLoginScreen extends HookConsumerWidget {
  const SellerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Gagal'),
            content: Text(next.error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final obscurePassword = useState(true);

    void submit() {
      if (formKey.currentState!.validate()) {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        // Check if the email is the authorized seller email
        if (email != 'indra020204@gmail.com') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email ini tidak terdaftar sebagai Seller'), backgroundColor: AppTheme.error),
          );
          return;
        }

        ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
              email,
              password,
            );
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              border: Border.all(color: AppTheme.surfaceContainerHighest),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront, size: 64, color: AppTheme.secondary),
                  const SizedBox(height: 16),
                  Text('Seller Login', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.secondary)),
                  const SizedBox(height: 8),
                  Text('Masuk untuk mengelola toko Anda', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Seller',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Password tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 24),


                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: AppTheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: authState.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.onSecondary, strokeWidth: 2))
                        : const Text('Masuk Ke Dashboard Seller', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
