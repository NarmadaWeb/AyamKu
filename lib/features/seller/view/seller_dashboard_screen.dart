import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
            onPressed: () => _showAddProductDialog(context, ref),
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
                children: products.map((p) => ListTile(
                  leading: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                  title: Text(p.name),
                  subtitle: Text('${currencyFormat.format(p.price)} • Stok: ${p.stock}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primary),
                    onPressed: () => _showAddProductDialog(context, ref, product: p),
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
        statusColor = AppTheme.secondary;
        break;
      case 'Dalam Pengiriman':
        nextStatusLabel = 'Selesaikan';
        nextStatus = 'Selesai';
        statusColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${order.id.substring(0, 8)}', style: Theme.of(context).textTheme.labelLarge),
                  Text(order.userName, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: Text(order.status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor)),
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.items.map((item) => Text('• $item')),
          const SizedBox(height: 8),
          Text('Total: ${currencyFormat.format(order.totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (order.paymentProofUrl != null && order.paymentProofUrl!.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => _showPaymentProofDialog(context, order.paymentProofUrl!),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Lihat Bukti Pembayaran'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
            const SizedBox(height: 12),
          ],
          if (nextStatus.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, nextStatus),
                child: Text(nextStatusLabel),
              ),
            ),
        ],
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

  void _showAddProductDialog(BuildContext context, WidgetRef ref, {ProductModel? product}) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );
  }
}

class _ProductFormDialog extends HookConsumerWidget {
  final ProductModel? product;
  const _ProductFormDialog({this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: product?.name);
    final priceController = useTextEditingController(text: product?.price.toString());
    final stockController = useTextEditingController(text: product?.stock.toString() ?? '0');
    final descController = useTextEditingController(text: product?.description);
    final weightController = useTextEditingController(text: product?.weight);
    final unitController = useTextEditingController(text: product?.unit ?? '/pack');
    final categoryController = useTextEditingController(text: product?.category ?? 'Ayam');
    final imageUrl = useState(product?.imageUrl ?? '');
    final isUploading = useState(false);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        isUploading.value = true;
        try {
          final url = await ref.read(productRepositoryProvider).uploadProductImage(File(image.path));
          imageUrl.value = url;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal upload gambar: $e'), backgroundColor: AppTheme.error),
            );
          }
        } finally {
          isUploading.value = false;
        }
      }
    }

    return AlertDialog(
      title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isUploading.value ? null : pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl.value.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl.value), fit: BoxFit.cover)
                      : null,
                ),
                child: isUploading.value
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl.value.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: AppTheme.onSurfaceVariant),
                              SizedBox(height: 8),
                              Text('Upload Gambar Produk'),
                            ],
                          )
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Produk')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Berat (misal: 500g)')),
            TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (misal: /pack)')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategori')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Deskripsi')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: isUploading.value ? null : () {
            if (imageUrl.value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silakan upload gambar produk terlebih dahulu')),
              );
              return;
            }
            final newProduct = ProductModel(
              id: product?.id ?? '',
              name: nameController.text,
              price: double.tryParse(priceController.text) ?? 0.0,
              description: descController.text,
              weight: weightController.text,
              imageUrl: imageUrl.value,
              unit: unitController.text,
              category: categoryController.text,
              isAvailable: true,
              stock: int.tryParse(stockController.text) ?? 0,
            );
            if (product == null) {
              ref.read(productRepositoryProvider).addProduct(newProduct);
            } else {
              ref.read(productRepositoryProvider).updateProduct(newProduct);
            }
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
