import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/product_repository.dart';
import '../model/product_model.dart';
import '../../cart/repository/cart_repository.dart';
import '../../cart/model/cart_item_model.dart';

class ProductDetailScreen extends HookConsumerWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productId = GoRouterState.of(context).pathParameters['id'];
    final productsAsync = ref.watch(productsProvider);
    final quantity = useState(1);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: productsAsync.when(
        data: (products) {
          final product = products.where((p) => p.id == productId).firstOrNull;

          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Produk tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(context, product),
                    _buildProductInfo(context, product, currencyFormat),
                  ],
                ),
              ),
              _buildBottomAction(context, product, quantity, ref),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, ProductModel product) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _badge(Icons.today, 'Fresh Today', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
              const SizedBox(height: 8),
              _badge(Icons.ac_unit, 'Freezer Free', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
              const SizedBox(height: 8),
              _badge(Icons.verified, 'Halal', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String text, Color bg, Color color, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, ProductModel product, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currencyFormat.format(product.price), style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(product.unit, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Berat Produk', style: Theme.of(context).textTheme.labelLarge),
              Text(product.weight, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stok Tersedia', style: Theme.of(context).textTheme.labelLarge),
              Text('${product.stock} ${product.unit.replaceAll('/', '')}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: product.stock > 0 ? AppTheme.primary : AppTheme.error)),
            ],
          ),
          const SizedBox(height: 24),

          Text('Catatan Pesanan (Opsional)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan untuk pesanan ini...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outline),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cutOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) {},
            activeColor: AppTheme.primary,
          ),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, ProductModel product, ValueNotifier<int> quantity, WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.outline),
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity.value > 1) quantity.value--;
                    },
                  ),
                  Text('${quantity.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppTheme.primary),
                    onPressed: () {
                      if (quantity.value < product.stock) {
                        quantity.value++;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stok tidak mencukupi')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: product.stock <= 0 ? null : () {
                  if (quantity.value > product.stock) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stok tidak mencukupi')),
                    );
                    return;
                  }
                  ref.read(cartRepositoryProvider).addToCart(CartItemModel(
                    id: '',
                    productId: product.id,
                    name: product.name,
                    price: product.price,
                    imageUrl: product.imageUrl,
                    quantity: quantity.value,
                    unit: product.unit,
                    weight: product.weight,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text(product.stock <= 0 ? 'Stok Habis' : 'Tambah ke Keranjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63939),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
