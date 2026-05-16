import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../home/repository/notification_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../repository/product_repository.dart';
import '../model/product_model.dart';
import '../../cart/repository/cart_repository.dart';
import '../../cart/model/cart_item_model.dart';

class CatalogScreen extends HookConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final selectedFilter = useState('Filter');

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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(selectedFilter),
          Expanded(
            child: productsAsync.when(
              data: (products) => _buildProductGrid(context, products, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari Ayam Dada, Ayam Paha...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
          filled: true,
          fillColor: AppTheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppTheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppTheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(ValueNotifier<String> selectedFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip('Filter', Icons.tune, selectedFilter),
          const SizedBox(width: 8),
          _filterChip('Berat', null, selectedFilter),
          const SizedBox(width: 8),
          _filterChip('Harga', null, selectedFilter),
          const SizedBox(width: 8),
          _filterChip('Jenis Ayam', null, selectedFilter),
          const SizedBox(width: 8),
          _filterChip('Potongan', null, selectedFilter),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData? icon, ValueNotifier<String> selectedFilter) {
    final isSelected = selectedFilter.value == label;
    return GestureDetector(
      onTap: () => selectedFilter.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<ProductModel> products, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _catalogCard(context, product, ref);
      },
    );
  }

  Widget _catalogCard(BuildContext context, ProductModel product, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceContainerHighest),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(product.imageUrl, fit: BoxFit.cover, color: product.stock <= 0 ? Colors.black.withValues(alpha: 0.5) : null, colorBlendMode: product.stock <= 0 ? BlendMode.darken : null),
                  if (product.stock <= 0)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('HABIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stock <= 0 ? AppTheme.error : AppTheme.secondary,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(product.stock <= 0 ? Icons.error_outline : Icons.verified, color: AppTheme.onSecondary, size: 14),
                          const SizedBox(width: 4),
                          Text(product.stock <= 0 ? 'Stok Habis' : 'Fresh Today', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(product.weight, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rp ${product.price.toInt()}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        GestureDetector(
                          onTap: product.stock <= 0 ? null : () async {
                            try {
                              await ref.read(cartRepositoryProvider).addToCart(CartItemModel(
                                id: '',
                                productId: product.id,
                                name: product.name,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                quantity: 1,
                                unit: product.unit,
                                weight: product.weight,
                              ));
                              if (context.mounted) {
                                AppDialogs.showAddToCartDialog(
                                  context: context,
                                  productName: product.name,
                                  onGoToCart: () => context.go('/cart'),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppDialogs.showErrorDialog(
                                  context: context,
                                  title: 'Gagal',
                                  message: e.toString().replaceAll('Exception: ', ''),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: product.stock <= 0 ? AppTheme.outline : AppTheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: AppTheme.onPrimary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceContainerLowest,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          switch(index) {
            case 0: context.go('/'); break;
            case 1: break; // Current
            case 2: context.go('/cart'); break;
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
