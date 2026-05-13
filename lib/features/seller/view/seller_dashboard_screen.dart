import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/repository/notification_repository.dart';
import '../../orders/repository/order_repository.dart';
import '../../orders/model/order.dart';
import '../../product/repository/product_repository.dart';
import '../../product/model/product_model.dart';
import 'package:intl/intl.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final productsAsync = ref.watch(productsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar Seller', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        actions: [
          IconButton(
            icon: ref.watch(unreadNotificationsCountProvider).when(
              data: (count) => count > 0
                ? Badge(
                    label: Text(count.toString()),
                    backgroundColor: AppTheme.primary,
                    child: const Icon(Icons.notifications, color: AppTheme.primary),
                  )
                : const Icon(Icons.notifications, color: AppTheme.primary),
              loading: () => const Icon(Icons.notifications, color: AppTheme.primary),
              error: (_, __) => const Icon(Icons.notifications, color: AppTheme.primary),
            ),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.add_box, color: AppTheme.primary),
            onPressed: () => context.push('/seller/add-product'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Penjual', style: Theme.of(context).textTheme.headlineMedium),
                    Text('Ringkasan toko Anda hari ini', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Mode Pembeli'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            allOrdersAsync.when(
              data: (orders) => _buildStatsGrid(context, orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 24),
            Text('Pesanan Aktif', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            allOrdersAsync.when(
              data: (orders) {
                final activeOrders = orders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').toList();
                if (activeOrders.isEmpty) return const Center(child: Text('Tidak ada pesanan aktif'));
                return Column(
                  children: activeOrders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderCard(context, order, ref, currencyFormat),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 24),
            Text('Kelola Produk', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            productsAsync.when(
              data: (products) => Column(
                children: products.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${currencyFormat.format(p.price)} • Stok: ${p.stock}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary),
                          onPressed: () => context.push('/seller/edit-product/${p.id}'),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _showDeleteConfirmation(context, ref, p),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, List<OrderModel> orders) {
    final completedOrders = orders.where((o) => o.status == 'Selesai').toList();
    final totalSales = completedOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final activeOrdersCount = orders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').length;

    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(context, 'Total Penjualan', currencyFormat.format(totalSales), Icons.payments, AppTheme.primary, AppTheme.primaryContainer.withValues(alpha: 0.2)),
        _statCard(context, 'Order Aktif', activeOrdersCount.toString(), Icons.receipt_long, AppTheme.secondary, AppTheme.secondaryContainer.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, WidgetRef ref, NumberFormat currencyFormat) {
    String nextStatusLabel = '';
    String nextStatus = '';
    Color statusColor = AppTheme.primary;

    switch(order.status) {
      case 'Menunggu Konfirmasi':
        nextStatusLabel = 'Terima & Proses';
        nextStatus = 'Dalam Proses Packing';
        statusColor = AppTheme.error;
        break;
      case 'Dalam Proses Packing':
        nextStatusLabel = 'Kirim Pesanan';
        nextStatus = 'Dalam Pengiriman';
        statusColor = Colors.orange;
        break;
      case 'Dalam Pengiriman':
        nextStatusLabel = 'Selesaikan';
        nextStatus = 'Selesai';
        statusColor = Colors.blue;
        break;
      case 'Selesai':
        statusColor = Colors.green;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${order.id.substring(0, 8).toUpperCase()}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(order.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(order.userPhone, style: Theme.of(context).textTheme.bodySmall),
                      Text(order.userAddress, style: Theme.of(context).textTheme.bodySmall),
                      if (order.latitude != null && order.longitude != null)
                        GestureDetector(
                          onTap: () async {
                            final url = 'https://www.google.com/maps/search/?api=1&query=${order.latitude},${order.longitude}';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.blue),
                                SizedBox(width: 4),
                                Text('Buka di Maps', style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                      Text(order.paymentMethod, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontSize: 10)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(order.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(height: 20),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: Theme.of(context).textTheme.bodyMedium),
            )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan', style: Theme.of(context).textTheme.bodySmall),
                Text(currencyFormat.format(order.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            if (order.paymentProofUrl != null && order.paymentProofUrl!.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPaymentProofDialog(context, order.paymentProofUrl!),
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Lihat Bukti Pembayaran'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (nextStatus.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, nextStatus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(nextStatusLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(productRepositoryProvider).deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
