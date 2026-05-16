import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../repository/order_repository.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String orderId;
  const PaymentWebViewScreen({super.key, required this.url, required this.orderId});

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
              // Midtrans often redirects or has specific success markers in URL
              debugPrint('Midtrans Redirect URL: $url');
              if (url.contains('transaction_status=settlement') ||
                  url.contains('transaction_status=capture') ||
                  url.contains('status_code=200') ||
                  url.contains('/finish')) {
                _onPaymentSuccess();
              } else if (url.contains('transaction_status=deny') ||
                         url.contains('transaction_status=cancel') ||
                         url.contains('transaction_status=expire') ||
                         url.contains('/error')) {
                _onPaymentFailed();
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView Error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Prevent navigating away from payment flow unless it's a known success/fail URL
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } else {
      // For Web, we trigger the redirect immediately after build or via button
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchPaymentUrl();
      });
    }
  }

  Future<void> _launchPaymentUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppDialogs.showErrorDialog(
          context: context,
          title: 'Gagal Membuka Pembayaran',
          message: 'Tidak dapat membuka halaman pembayaran. Silakan coba lagi.',
        );
      }
    }
  }

  void _onPaymentSuccess() async {
    if (mounted) {
      // Update order status in Supabase if URL indicates success
      try {
        await ref.read(orderRepositoryProvider).updateOrder(widget.orderId, {
          'paymentStatus': 'success',
          'status': 'Dalam Proses Packing',
        });
      } catch (e) {
        debugPrint('Failed to auto-update order status: $e');
      }

      if (mounted) {
        AppDialogs.showSuccessDialog(
          context: context,
          title: 'Pembayaran Berhasil!',
          message: 'Terima kasih telah berbelanja di AyamSegar.',
          onPressed: () => context.go('/orders'),
        );
      }
    }
  }

  void _onPaymentFailed() {
    if (mounted) {
      AppDialogs.showErrorDialog(
        context: context,
        title: 'Pembayaran Gagal',
        message: 'Pembayaran Anda gagal atau dibatalkan. Silakan coba lagi.',
      );
      context.go('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans'),
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 64, color: AppTheme.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Lanjutkan Pembayaran di Jendela Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jika halaman pembayaran tidak terbuka otomatis,\nsilakan klik tombol di bawah ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _launchPaymentUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buka Halaman Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('Kembali ke Pesanan Saya'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  void _showCancelDialog() {
    AppDialogs.showConfirmDialog(
      context: context,
      title: 'Batalkan Pembayaran?',
      message: 'Apakah Anda yakin ingin keluar dari halaman pembayaran?',
      confirmText: 'Ya, Keluar',
      confirmColor: AppTheme.error,
      onConfirm: () {
        context.go('/orders');
      },
      cancelText: 'Lanjutkan Pembayaran',
    );
  }
}
