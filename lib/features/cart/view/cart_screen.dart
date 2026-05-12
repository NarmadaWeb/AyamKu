import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../home/repository/notification_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/cart_repository.dart';
import '../model/cart_item_model.dart';
import 'package:intl/intl.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
              loading: () => const Icon(Icons.notifications),
              error: (_, __) => const Icon(Icons.notifications),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: cartItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Keranjang Anda Kosong', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('Belanja Sekarang'),
                  ),
                ],
              ),
            );
          }

          final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
          final shipping = 15000.0;
          final total = subtotal + shipping;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Keranjang Anda', style: Theme.of(context).textTheme.headlineMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(100)),
                            child: Text('${items.length} Item', style: Theme.of(context).textTheme.labelSmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _cartItem(context, item, ref, currencyFormat),
                      )),
                      const SizedBox(height: 24),
                      _buildSummary(context, subtotal, shipping, total, currencyFormat),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lanjut ke Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(context),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _cartItem(BuildContext context, CartItemModel item, WidgetRef ref, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.onSurfaceVariant, size: 20),
                      onPressed: () => ref.read(cartRepositoryProvider).removeFromCart(item.id),
                    ),
                  ],
                ),
                Text('${item.weight} • ${item.unit}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormat.format(item.price), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16, color: AppTheme.onSurfaceVariant),
                            onPressed: () => ref.read(cartRepositoryProvider).updateQuantity(item.id, item.quantity - 1),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(cartRepositoryProvider).updateQuantity(item.id, item.quantity + 1),
                            child: Container(
                              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.add, size: 16, color: AppTheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal, double shipping, double total, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Pesanan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              Text(currencyFormat.format(subtotal), style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 4),
                  Text('Estimasi Ongkos Kirim', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
              Text(currencyFormat.format(shipping), style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
              Text(currencyFormat.format(total), style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppTheme.primary)),
            ],
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
        currentIndex: 2,
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
            case 2: break;
            case 3: context.go('/orders'); break;
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
