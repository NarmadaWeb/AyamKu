import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
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
            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture') ||
                url.contains('/finish')) {
              _onPaymentSuccess();
            } else if (url.contains('transaction_status=deny') ||
                       url.contains('transaction_status=cancel') ||
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran Berhasil!'), backgroundColor: Colors.green),
        );
        context.go('/orders');
      }
    }
  }

  void _onPaymentFailed() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran Gagal atau Dibatalkan'), backgroundColor: AppTheme.error),
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin keluar dari halaman pembayaran?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan Pembayaran'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/orders');
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
