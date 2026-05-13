import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../orders/model/order.dart';
import '../../orders/repository/order_repository.dart';

class SellerOrderDetailScreen extends HookConsumerWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: AppTheme.surface,
      ),
      body: allOrdersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId, orElse: () => throw Exception('Order not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(context, order),
                const SizedBox(height: 16),
                _buildCustomerInfo(context, order),
                const SizedBox(height: 16),
                if (order.latitude != null && order.longitude != null) ...[
                  _buildMapLocation(context, order),
                  const SizedBox(height: 16),
                ],
                _buildOrderItems(context, order, currencyFormat),
                const SizedBox(height: 16),
                _buildPaymentInfo(context, order, currencyFormat),
                const SizedBox(height: 32),
                _buildStatusActions(context, ref, order),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderModel order) {
    Color statusColor = AppTheme.primary;
    switch (order.status) {
      case 'Menunggu Konfirmasi': statusColor = AppTheme.error; break;
      case 'Dalam Proses Packing': statusColor = Colors.orange; break;
      case 'Dalam Pengiriman': statusColor = Colors.blue; break;
      case 'Selesai': statusColor = Colors.green; break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID Pesanan', style: Theme.of(context).textTheme.labelSmall),
              Chip(
                label: Text(order.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: statusColor,
              ),
            ],
          ),
          Text(order.id.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          Text('Waktu Pemesanan', style: Theme.of(context).textTheme.labelSmall),
          Text(DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Informasi Pelanggan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:${order.userPhone}')),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(order.userPhone, style: const TextStyle(color: AppTheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Alamat Pengiriman', style: Theme.of(context).textTheme.labelSmall),
          Text(order.userAddress),
          const SizedBox(height: 8),
          Text('Slot Waktu Pengiriman', style: Theme.of(context).textTheme.labelSmall),
          Text(order.deliveryTimeSlot, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMapLocation(BuildContext context, OrderModel order) {
    final mapUrl = 'https://maps.google.com/maps?q=${order.latitude},${order.longitude}&z=15&output=embed';
    final controller = useMemoized(() => WebViewController());

    useEffect(() {
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      // Load Google Maps as an iframe to satisfy Embed API requirements in WebView
      final html = '''
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { margin: 0; padding: 0; }
              iframe { width: 100vw; height: 100vh; border: 0; }
            </style>
          </head>
          <body>
            <iframe src="$mapUrl" allowfullscreen></iframe>
          </body>
        </html>
      ''';
      controller.loadHtmlString(html);
      return null;
    }, [order.latitude, order.longitude]);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            // Overlay to intercept taps and open Google Maps app
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final url = 'https://www.google.com/maps/search/?api=1&query=${order.latitude},${order.longitude}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: FloatingActionButton.small(
                onPressed: () async {
                  final url = 'https://www.google.com/maps/search/?api=1&query=${order.latitude},${order.longitude}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.directions, color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, OrderModel order, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Daftar Produk', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(item.toString())),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, OrderModel order, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Informasi Pembayaran', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _paymentRow('Metode Pembayaran', order.paymentMethod),
          _paymentRow('Status Pembayaran', order.paymentStatus.toUpperCase()),
          const Divider(),
          _paymentRow('Total Tagihan', currencyFormat.format(order.totalPrice), isBold: true),
          if (order.paymentProofUrl != null && order.paymentProofUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPaymentProofDialog(context, order.paymentProofUrl!),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Lihat Bukti Pembayaran'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppTheme.primary : null)),
        ],
      ),
    );
  }

  Widget _buildStatusActions(BuildContext context, WidgetRef ref, OrderModel order) {
    String nextStatusLabel = '';
    String nextStatus = '';

    switch (order.status) {
      case 'Menunggu Konfirmasi':
        nextStatusLabel = 'Terima & Proses Pesanan';
        nextStatus = 'Dalam Proses Packing';
        break;
      case 'Dalam Proses Packing':
        nextStatusLabel = 'Kirim Pesanan';
        nextStatus = 'Dalam Pengiriman';
        break;
      case 'Dalam Pengiriman':
        nextStatusLabel = 'Selesaikan Pesanan';
        nextStatus = 'Selesai';
        break;
    }

    if (nextStatus.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, nextStatus);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status diperbarui menjadi $nextStatus'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui status: $e'), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(nextStatusLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        if (order.status == 'Menunggu Konfirmasi') ...[
           const SizedBox(height: 12),
           SizedBox(
             width: double.infinity,
             child: TextButton(
               onPressed: () => _showCancelConfirmation(context, ref, order),
               child: const Text('Batalkan Pesanan', style: TextStyle(color: AppTheme.error)),
             ),
           ),
        ],
      ],
    );
  }

  void _showPaymentProofDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bukti Pembayaran'),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () async {
              await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, 'Dibatalkan');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan dibatalkan')));
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
