import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../home/repository/notification_repository.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/order_repository.dart';
import '../model/order.dart';
import '../repository/midtrans_service.dart';

class OrdersScreen extends HookConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(userOrdersProvider);

    // Auto-check pending Midtrans payments on entry
    useEffect(() {
      final orders = ordersState.asData?.value;
      if (orders != null && !kIsWeb) {
        for (final order in orders) {
          if (order.paymentStatus == 'pending' &&
              order.paymentMethod != 'Bayar di Tempat (COD)' &&
              order.status == 'Menunggu Konfirmasi') {

            // Check Midtrans status in background
            Future.microtask(() async {
              try {
                final midtransId = order.midtransOrderId ?? order.id;
                final status = await ref.read(midtransServiceProvider).checkTransactionStatus(midtransId);
                final transactionStatus = status['transaction_status'];

                if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
                  await ref.read(orderRepositoryProvider).updateOrder(order.id, {
                    'paymentStatus': 'success',
                    'status': 'Dalam Proses Packing',
                  });
                }
              } catch (e) {
                debugPrint('Auto-check Midtrans failed for ${order.id}: $e');
              }
            });
          }
        }
      }
      return null;
    }, [ordersState.asData?.value.length]);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
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
        ],
      ),
      body: ordersState.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          final activeOrders = orders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').toList();
          final pastOrders = orders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeOrders.isNotEmpty) ...[
                  Text('Pesanan Aktif', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  ...activeOrders.map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActiveOrder(context, o, ref),
                      )),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Riwayat Pesanan', style: Theme.of(context).textTheme.headlineSmall),
                    TextButton(
                      onPressed: () => context.push('/order-history'),
                      child: const Row(
                        children: [
                          Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (pastOrders.isEmpty) const Text('Belum ada riwayat pesanan.'),
                ...pastOrders.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPastOrder(
                        context,
                        '${DateFormat('dd MMM yyyy').format(o.createdAt)} • ${o.status}',
                        o.totalPrice.toStringAsFixed(0),
                        o.items.isNotEmpty ? o.items.first.toString() : 'Pesanan',
                        o.items.length > 1 ? '+${o.items.length - 1} item lainnya' : '',
                        null,
                        true,
                      ),
                    )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildActiveOrder(BuildContext context, OrderModel order, WidgetRef ref) {
    bool isPaid = order.paymentStatus == 'success';
    bool isCOD = order.paymentMethod == 'Bayar di Tempat (COD)';
    bool isConfirmed = order.status != 'Menunggu Konfirmasi';
    bool inTransit = order.status == 'Dalam Pengiriman';
    bool isDone = order.status == 'Selesai';

    // Payment proof is needed ONLY IF it's not COD, not yet paid via Midtrans, and no proof uploaded yet
    bool needsPaymentProof = !isCOD && !isPaid && (order.paymentProofUrl == null || order.paymentProofUrl!.isEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Pesanan', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                  Text(order.id.length > 8 ? order.id.substring(0, 8) : (order.id.isEmpty ? 'Baru' : order.id), style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, size: 14, color: AppTheme.onSecondaryContainer),
                        const SizedBox(width: 4),
                        Text(order.status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (order.paymentMethod != 'Bayar di Tempat (COD)')
                    Text(
                      order.paymentStatus == 'success' ? 'LUNAS' : 'BELUM BAYAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: order.paymentStatus == 'success' ? Colors.green : Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (needsPaymentProof) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryContainer),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Silakan upload bukti pembayaran agar pesanan Anda dapat segera dikonfirmasi.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showUploadProofDialog(context, order.id, ref),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Bukti Pembayaran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (order.paymentProofUrl != null && order.paymentProofUrl!.isNotEmpty) ...[
             const Row(
               children: [
                 Icon(Icons.check_circle, color: Colors.green, size: 16),
                 SizedBox(width: 8),
                 Text('Bukti pembayaran telah diunggah', style: TextStyle(fontSize: 12, color: Colors.green)),
               ],
             ),
             const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 16),
          _timelineItem(context, Icons.payments, 'Pembayaran', (isPaid || isCOD) ? 'Pembayaran Berhasil' : 'Menunggu Pembayaran', (isPaid || isCOD), true, isCurrent: !(isPaid || isCOD)),
          _timelineItem(context, Icons.receipt_long, 'Konfirmasi', isConfirmed ? 'Pesanan Dikonfirmasi' : 'Menunggu Konfirmasi Seller', isConfirmed, true, isCurrent: (isPaid || isCOD) && !isConfirmed),
          _timelineItem(context, Icons.local_shipping, 'Pengiriman', inTransit ? 'Dalam Perjalanan' : 'Pesanan Sedang Dipacking', inTransit, true, isCurrent: isConfirmed && !inTransit),
          _timelineItem(context, Icons.home, 'Selesai', 'Pesanan Sampai Tujuan', isDone, false, isCurrent: inTransit && !isDone),
          if (!isPaid && !isCOD) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                   if (kIsWeb) {
                     AppDialogs.showErrorDialog(
                       context: context,
                       title: 'Fitur Tidak Tersedia',
                       message: 'Cek status otomatis tidak tersedia di web karena batasan keamanan browser. Silakan gunakan aplikasi mobile atau tunggu beberapa saat hingga sistem memperbarui status Anda secara otomatis.',
                     );
                     return;
                   }

                   try {
                     final midtransId = order.midtransOrderId ?? order.id;
                     final status = await ref.read(midtransServiceProvider).checkTransactionStatus(midtransId);
                     final transactionStatus = status['transaction_status'];
                     if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
                       await ref.read(orderRepositoryProvider).updateOrder(order.id, {'paymentStatus': 'success', 'status': 'Dalam Proses Packing'});
                       if (context.mounted) {
                         AppDialogs.showSuccessDialog(
                           context: context,
                           title: 'Berhasil',
                           message: 'Pembayaran berhasil dikonfirmasi!',
                         );
                       }
                     } else {
                        if (context.mounted) {
                          AppDialogs.showErrorDialog(
                            context: context,
                            title: 'Status Pembayaran',
                            message: 'Status: ${transactionStatus ?? 'Tidak diketahui'}',
                          );
                        }
                     }
                   } catch (e) {
                     if (context.mounted) {
                       AppDialogs.showErrorDialog(
                         context: context,
                         title: 'Gagal',
                         message: 'Gagal mengecek status: $e',
                       );
                     }
                   }
                },
                child: const Text('Cek Status Pembayaran'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showUploadProofDialog(BuildContext context, String orderId, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          await ref.read(orderRepositoryProvider).uploadPaymentProof(orderId, File(image.path));
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            AppDialogs.showSuccessDialog(
              context: context,
              title: 'Berhasil',
              message: 'Bukti pembayaran berhasil diunggah!',
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            AppDialogs.showErrorDialog(
              context: context,
              title: 'Gagal',
              message: 'Gagal mengunggah bukti: $e',
            );
          }
        }
      }
    }
  }

  Widget _timelineItem(BuildContext context, IconData icon, String title, String subtitle, bool isDone, bool showLine, {bool isCurrent = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppTheme.primary : (isDone ? AppTheme.secondary : AppTheme.surfaceContainerHigh),
                    shape: BoxShape.circle,
                    border: Border.all(color: isCurrent ? AppTheme.primaryContainer : (isDone ? AppTheme.secondary : AppTheme.surfaceContainerHighest), width: isCurrent ? 4 : 1),
                  ),
                  child: Icon(icon, size: 14, color: isDone || isCurrent ? Colors.white : AppTheme.onSurfaceVariant),
                ),
                if (showLine) Expanded(child: Container(width: 2, color: isDone ? AppTheme.secondary : AppTheme.surfaceContainerHighest)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isCurrent ? AppTheme.primary : (isDone ? AppTheme.onSurface : AppTheme.onSurfaceVariant))),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastOrder(BuildContext context, String date, String price, String title, String subtitle, String? imgUrl, bool isPrimaryBtn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
              Text('Rp $price', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const Divider(),
          Row(
            children: [
              if (imgUrl != null) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelLarge),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart, color: isPrimaryBtn ? AppTheme.onPrimary : AppTheme.onSurface),
              label: Text('Pesan Lagi', style: TextStyle(color: isPrimaryBtn ? AppTheme.onPrimary : AppTheme.onSurface)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimaryBtn ? AppTheme.primary : AppTheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceContainerLowest,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          switch(index) {
            case 0: context.go('/'); break;
            case 1: context.go('/catalog'); break;
            case 2: context.go('/cart'); break;
            case 3: break;
            case 4: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
