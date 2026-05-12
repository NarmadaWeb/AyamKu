import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../home/repository/notification_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/order_repository.dart';
import '../model/order.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(userOrdersProvider);

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
                        child: _buildActiveOrder(context, o),
                      )),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Riwayat Pesanan', style: Theme.of(context).textTheme.headlineSmall),
                    TextButton(
                      onPressed: () {},
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

  Widget _buildActiveOrder(BuildContext context, OrderModel order) {
    bool isConfirmed = order.status != 'Menunggu Konfirmasi';
    bool inTransit = order.status == 'Dalam Pengiriman';
    bool isDone = order.status == 'Selesai';

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
                  Text(order.id.isEmpty ? 'Baru' : order.id, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
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
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _timelineItem(context, Icons.receipt_long, 'Pesanan Diproses', DateFormat('hh:mm a').format(order.createdAt), true, true),
          _timelineItem(context, Icons.content_cut, 'Pesanan di konfirmasi', 'Pesanan sedang disiapkan', isConfirmed, true),
          _timelineItem(context, Icons.local_shipping, 'Pesanan sedang di dalam perjalanan', 'Kurir menuju lokasi Anda', inTransit, true, isCurrent: inTransit),
          _timelineItem(context, Icons.home, 'Sampai Tujuan', 'Pesanan selesai', isDone, false),
        ],
      ),
    );
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
