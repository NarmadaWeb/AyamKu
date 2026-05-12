import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../product/repository/product_repository.dart';
import '../../product/model/product_model.dart';
import '../../cart/repository/cart_repository.dart';
import '../../cart/model/cart_item_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
        surfaceTintColor: Colors.transparent,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Badge(
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.notifications, color: AppTheme.onSurfaceVariant),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(context),
            _buildCategories(context),
            productsAsync.when(
              data: (products) => _buildPopularProducts(context, products, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAuCK1RcHZ6b4uIoDucltteP0kx5WFtCw7atcPaEPxUp1H5BeRbY7qV3s9gsRNj8HhnrK519BmAwMmnsNuTU8h2HNdRDclsrp3YN3qpjd0hzTuEouUCBUzZBB9_hzCe2mj9f--xuGfh3BsnO8ZlH_j2bRwFL1nOYaw_h06FPgfWV6-vryVNHPBaqtHaAk-GQ2dQas2N6S3qkiz42GTZPN7tRo_4m-pF_dWH9p1K7AaqUNtj6wQzgqrq8YrbfNdAUJUHklRxAJVzng'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: AppTheme.onSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text('Fresh 100%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  'Ayam Baru Dipotong Hari Ini',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Order Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'name': 'Ayam Broiler', 'icon': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAT8UGB-IcP4uGH2TlfjhxoU8msSs2b5b5vrupPsHRGJZn6ghlcKH63HSINciGKZeUBj3potr2khvW5mZ_9VKsrShh2NYo7i1e9c-g-R7ce9EGN7xjR19v7JrrObJMLSjKpn1Dq6FBYj5yhL3qv_0acLCmno4LHJscLUIlP4HnGv_so7D-qY2OvgQ8jCp5UE7uIKKK-cIkpqGZ3HhQaUzUXG-9NiUfKgPF_hIlRTCW3GFriQDg30eyd7vI8rcnoaiyISBF4eFfeMA'},
      {'name': 'Ayam Kampung', 'icon': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2J71pRX8Vf55TeWfo0ehajOfcMCL6TPzaa_xhhZtXifYb3inmpqiDCA6CZU_WZTeOYlIDb4UcFMKFs06jX1EWQFoHl5fowOcV9Q7txnSROzsCPVUbfCtC5T-6-i81n52enBFo-46J6oONGBMYhA3bF_m_QAqWKVZ4kLnPVzh1Sh_kdqs6lJhbjeP4m6MEQucUyWFP0xnrO9KsExP1fNM4AA-XrBqAMALiCHhzEV9k81UGTRnctUJSUzmU9Wz1g0F69WXm6LxylA'},
      {'name': 'Ayam K. Super', 'icon': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBzHYdj7uMSFEZDpVicxrA7XiHJ3885r7t8-1dkQW6pShpZnpfwO6dseD6W2TYuH9Eu46akLEniFIux-WEEwSDUfweJCEGs29zzBU8Lqo1ZiIWaO0cnqVKad1Z1DdJrnl7sRNdwL4wopl-Rg44sS1f0HMoUAwUsc0Bsu443RvpbbR0oel_k7-d8dDZQ5E1YJD3gklaVdIvf84Bt1e8W1mNEBMGahaPTcq0p5fNBC-XeoNEB1g0D10DRECgppa0nwRoyAer0tOaqiw'},
      {'name': 'Telur Segar', 'materialIcon': Icons.egg_alt},
      {'name': 'Potongan', 'materialIcon': Icons.restaurant_menu},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Kategori Pilihan', style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceContainerHighest),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: cat.containsKey('icon')
                            ? Image.network(cat['icon'] as String, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.8))
                            : Icon(cat['materialIcon'] as IconData, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat['name'] as String,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProducts(BuildContext context, List<ProductModel> products, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ayam Paling Laris', style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length > 4 ? 4 : products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return _productCard(context, product, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, ProductModel product, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceContainerHighest),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                  Image.network(product.imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.ac_unit, size: 10, color: AppTheme.secondary),
                          const SizedBox(width: 2),
                          Text('Chilled', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: AppTheme.secondary)),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: Theme.of(context).textTheme.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(product.weight, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Rp ${product.price.toInt()}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary),
                            children: [
                              TextSpan(text: product.unit, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: AppTheme.onPrimary, size: 18),
                            onPressed: () {
                              ref.read(cartRepositoryProvider).addToCart(CartItemModel(
                                id: '',
                                productId: product.id,
                                name: product.name,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                quantity: 1,
                                unit: product.unit,
                                weight: product.weight,
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
                              );
                            },
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
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

  Widget _buildPromo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: AppTheme.onPrimaryContainer, size: 16),
                    const SizedBox(width: 4),
                    Text('Promo Hari Ini', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onPrimaryContainer)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Gratis ongkir min. belanja Rp 100rb', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onPrimaryContainer.withValues(alpha: 0.8))),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainerLowest,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Klaim'),
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
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceContainerLowest,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          switch(index) {
            case 1: context.go('/catalog'); break;
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
