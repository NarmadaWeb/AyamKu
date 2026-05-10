import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildPopularProducts(context),
            _buildPromo(context),
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

  Widget _buildPopularProducts(BuildContext context) {
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: [
              _productCard(context, 'Ayam Broiler Utuh Bersih', '~1.0 - 1.2 kg', '35.000', '/ekor', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDkXxiKL6lXK-8ycblvay20jB-dOJfU2P8sACxeyAW-YFirEfAhHCKN1eXDDTQpJjcfCmvlkq4aYb596RA98WvEoguQJOEh7J3LliKuoKgZv4Tya2M3_Y4rv8vmULReDWsMcNpca3P1M-7b8xTgEmYorLyJfafa116KRXUyLiV40BYCJ1LA_ldztab6HoGT8avNZes3pRabVkyIkVwaPjmeWDrDriUQu-I-ccN4Ztc0WP6CL3ecWwha7eXfa3lStHGUsja--zt9ZQ'),
              _productCard(context, 'Dada Ayam Fillet', '500g', '28.000', '/pack', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDngNE2qG-LriV4sihPp-1dw0cIzKXGzV-e9QgXCn955tk4Fe5f8lA_Kf1EFLyBMxGkLSvNHv1x2qdkhnhnAg7W36mSjC5iT2spOOk2oOiN97wumgeQD18Z_9SAeTaqI2REFlaakDQvAS7CkJR4wG7o1b9lQMTzJ1Qao0xGzkapIARC8xq1QyfQAXUxxckc_3Wq-AWO7kMOE3jp4tvDx2x7q04d426HzwGxE6qSCKOg0K-O8ydH9GLCEt88fOz4daB956wYhXBWIQ'),
              _productCard(context, 'Paha Bawah (Drumstick)', '500g', '25.000', '/pack', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAyfpUrj6p1w6vPjkUM6BC3j6pcDMmqo1bwyxsES01Wp1OkAL5ZFZDtS1mMeDJD-OHyXqf_mvGL47ZpGBq-kfTkvprzrS-WgSJbb9BNSLLsVLtEQaOCl7DfBIc9t8I0JwsfCJM9jXGss58bmytJ0otn_50FddfdBp_vDSr-Ah-yNQiQvVlFZ8a3RwfLHnalzpoky03_c7kbdJilqxShkFMjLgclnFV-KOS3DdZJB1YpOgQLJcXRp5wRIuHvTys3ikV3gi54O8l_oQ'),
              _productCard(context, 'Telur Ayam Kampung Asli', '10 Butir', '22.000', '/pack', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCOmgu_0kiqzwgt2TNYH6Nx9CqFj3jADx7V28zniQXMyNLLmwXbVX3Iqiwrde6ufUSRZWu-bDC4ZfBtL80cvb0O6geeZZLPO6AmTpYGP7H0jIQRG_6tzd3e9-sOTIv7b5M4ts-Xg90lCaqpKv2gLZR9ztCySGGbYfYAW83vmXMl4WJLXyGWbOYUlxUCcrbigJ21JdmzNsjrnC5ogpfapsgp6-vM1nfO1cnff4Ev3JMkHTqgeDT0i6UNi7kRElxKAESV7MEB5BHQTw'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, String title, String weight, String price, String unit, String imageUrl) {
    return GestureDetector(
      onTap: () => context.push('/product/1'), // Mock ID
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
                  Image.network(imageUrl, fit: BoxFit.cover),
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
                        Text(title, style: Theme.of(context).textTheme.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(weight, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Rp $price',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary),
                            children: [
                              TextSpan(text: unit, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
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
                            onPressed: () {},
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
