import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primary),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Badge(
              backgroundColor: AppTheme.error,
              child: Icon(Icons.notifications, color: AppTheme.primary),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildProductGrid(context)),
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

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip('Filter', Icons.tune, true),
          const SizedBox(width: 8),
          _filterChip('Berat', null, false),
          const SizedBox(width: 8),
          _filterChip('Harga', null, false),
          const SizedBox(width: 8),
          _filterChip('Jenis Ayam', null, false),
          const SizedBox(width: 8),
          _filterChip('Potongan', null, false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData? icon, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryContainer : AppTheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isPrimary ? AppTheme.primaryContainer : AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isPrimary ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: [
        _catalogCard(context, 'Dada Ayam Fillet Premium', '± 500g / pack', '35.000', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmk6V2PghG7fyBs2mbBgkEhUjIdYfO8leBL8SZ9cRgtob-NzGAt9sO1pxd6eg01-txu2PDt35E6hRSGHDeii_s0rxSed4k75GsIYlO2V0QTtnQVOoFHgvZYG1FK8TcliZF7InGcjRk3nnzAH5vpdZ_1ULDmQSgfiQZWVfKn8J-DyXhD9Z7CqSVdVtx4ddWSA_vesKo22hcvU4_N5ERjP2Mr07ENLeZWHWwzPdlXTPzXSoAMhiLmmdxbpeyA4QbGgJ7C2rgVvFx-Q'),
        _catalogCard(context, 'Paha Bawah (Drumstick)', '± 1kg / pack', '45.000', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBUFQBK4bkWN6xfO7bMjlpAb3LfWYk9VabszJIhbyH0sk5blRqMEhPxNkPuxHCkjawUjqYR_XtNgA3UlW4YAW7k7fJNUHAK3RIxL3q2txTFslzG_XebUgxSU4xA8IzZDfvmO6Ul3yxhI2KYOG6EVfWu0Uww_fuc43NFHEHZv5s-N-VsVsMzPX1kuNs-MwRwGA0_WON7DT-JNBHWMgqmhiBSbLs70fwPsYGojw8QlD3iwusqNK2Z2NYoHH4a4abDPesUeOUQ8LbRMg'),
        _catalogCard(context, 'Sayap Ayam Utuh', '± 500g / pack', '28.000', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCgsnWOfhU3RZsYfTtPNxDP_yebKo0Mwz7TPfMgNNkj3xUsPWbB4qysVfkAKf5kCA6264qpJOw8ALXF7y-odyh16scvZVk8qW3SZW-2LW_m9sj5qL66-yqhSZqkgl5OTY_qob6PsKhz7MamKCoKSb5pvo4-9gjerTGd_1SCvql3YPf2vmzZbaudflpdKu9JEIDzuUnbnP1KHs_GWsZn03n0QS76vD4cWSLptzD_25ESyWLPTan35o-xkreJkrzTz7UdKbuBMy80iQ'),
        _catalogCard(context, 'Ayam Pejantan Utuh', '1 Ekor (± 800g)', '42.000', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDk9VzzNZ3lgmtim5Uw0BdQdU-q_-Q-PSmMG5pswCuP3EVgJ8RcpwZ-Dowmxaq7JZ2riHfiog5GUwMIOMs1WNDkGGpw0-9YKdG284NOXLwixTIgrkFf52rIn-cEvz68UU0rK0UKEAwWqLLUDeeKKPonHq_3S8n-0cDXBLM57yUmGPxoBHBzorLys166PcpQdtOflYW3IhiGXCgDry8WL00sr9SqIzhGTWInMBB1qhvOoE-firCkCEqIGU0wHYdXMZTX76g3fEvyKQ'),
      ],
    );
  }

  Widget _catalogCard(BuildContext context, String title, String subtitle, String price, String imageUrl) {
    return GestureDetector(
      onTap: () => context.push('/product/1'), // Mock ID
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
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: AppTheme.onSecondary, size: 14),
                          const SizedBox(width: 4),
                          Text('Fresh Today', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondary)),
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
                        Text(title, style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rp $price', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: AppTheme.onPrimary, size: 20),
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
