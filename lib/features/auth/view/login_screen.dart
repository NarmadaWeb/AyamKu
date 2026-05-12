import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final phoneController = useTextEditingController();
    final addressController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLogin = useState(true);

    void submit() {
      if (formKey.currentState!.validate()) {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        if (isLogin.value) {
          ref.read(authControllerProvider.notifier).signInWithEmailAndPassword(
                email,
                password,
              );
        } else {
          ref.read(authControllerProvider.notifier).createUserWithEmailAndPassword(
                email,
                password,
                phoneController.text.trim(),
                addressController.text.trim(),
              );
        }
      }
    }

    void handleForgotPassword() {
      if (emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan email terlebih dahulu untuk reset password')),
        );
        return;
      }
      ref.read(authControllerProvider.notifier).resetPassword(emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email reset password telah dikirim ke ${emailController.text}')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
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
                      Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary)),
                      const SizedBox(height: 8),
                      Text('Masuk atau daftar untuk melanjutkan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Email tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Password tidak boleh kosong' : null,
                      ),

                      if (!isLogin.value) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Nomor Handphone',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Nomor Handphone tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Alamat Lengkap',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Alamat tidak boleh kosong' : null,
                        ),
                      ],
                      const SizedBox(height: 8),

                      if (isLogin.value)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: handleForgotPassword,
                            child: const Text('Lupa Password?'),
                          ),
                        ),

                      const SizedBox(height: 16),

                      if (authState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authState.error.toString(),
                            style: const TextStyle(color: AppTheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: authState.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.onPrimary, strokeWidth: 2))
                            : Text(isLogin.value ? 'Masuk' : 'Daftar', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onPrimary)),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => isLogin.value = !isLogin.value,
                        child: Text(isLogin.value ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Masuk'),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('ATAU', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: authState.isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          icon: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuBnRNiJ3wrQSKeVYTbvTdW4CiYtwddISkExU2XJTXQRFWodhXf3vHNPHSZPtS6UB_HGuvzSloBH9cDcoB21zQJoiYHqdaibcrriZJhlceyQnJBFiVg4gtkQkTgNc1QJPLWueCLN7rpCa63tNCkgRRbV9ym2LYPzygoD3oz46oLY50yrGr_K4GCjWD1jAjvtX4f5Z5V5wPFhi34oeIAPG7oW5nptNq6CCsA0Jf2SM94MkaagFpdWA_gxkqsmsrCB_JsUnfBG5H5Qhg', width: 20, height: 20),
                          label: Text('Lanjutkan dengan Google', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurface)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
