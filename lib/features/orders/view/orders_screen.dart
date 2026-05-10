import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.menu, color: AppTheme.primary), onPressed: () {}),
        actions: [IconButton(icon: const Icon(Icons.notifications, color: AppTheme.primary), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan Aktif', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            _buildActiveOrder(context),
            const SizedBox(height: 24),
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
            _buildPastOrder(context, '12 Okt 2023 • Berhasil', '85.000', 'Ayam Pejantan Utuh (Potong 8)', '1x Dada Ayam Fillet, 1x Ati Ampela', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAk4xzz80FEaJQLpc4wOCxdV7kt9T_kqLKAEOuPS3FnFG7bJpCGkqKBAbOWRHiKDc__V-AWZmoJozzgIsZc9_6F3pWB-B_uFdWAlTYcGZLtpjCxakN-raoGLvyok8K5XABhcStxwPQrXqX6bKuEv7dTpQU1AWzX-5n4vSzOyosDGuJOirydWiQ0VEtxvap8XZaFz6SD9hgLtG-zpPa59Ei7De9YN0BBU1YwaVc_0RbfgYT8rnIZTHpU6EQfFX2DCiq7dauLF3K7bw', true),
            const SizedBox(height: 12),
            _buildPastOrder(context, '05 Okt 2023 • Berhasil', '45.000', 'Dada Ayam Fillet (500g)', '1x Bumbu Kuning Marinasi', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoCrlSea5hUaynfw6_AsB754sTDmTb_QKGdBcZDLjxzlhErpMJGfxZegP-GiIWXv0AGLnV19F8bcMgbt4-ZK9pHNPOMM2jeOSBaVaZDrGtmRglB-lI3JpJWhTA0H8YZmRoewIuLFDYOYVK1HQcJ_a2s8jw9GMFeAtmwsgIU9dIIA4-vr-CpcqOgtjlBtWE5I9biqW0RnPIZe-XUP312qzhEaVcto6kxyabdoMJZE8s7_qqYfsmFziYupYH_Vqk-I3a99BddpECQQ', false),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildActiveOrder(BuildContext context) {
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
                  Text('ORD-892471', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 14, color: AppTheme.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text('Dalam Pengiriman', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.surfaceContainerHighest),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCJ4b8E5k_5wzJewzRekhLHu7NMXKIcvUZ7H1yQC1BCBo3h5Z8bBZ3dPm9GlsMCay0xDzGt27knZDe5nJvbCPcuzAw69rMBbOEl3l0uF3EvyL7lmExAj3rSvQyXxQSF7Bctypcd84-5G1VxaRK1MMc93jGkaidQ8nXkq9XDL-e4bOqk_yrBIuAv9O3WPuk6O3V29fkqy_78fZer4sZtMzXfaNKhYzsTdi2KbLLr1NCUQ9umASxJhMEKs3lKpTiEKma0DMXbhHu9iw'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text('15 mnt lagi', style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _timelineItem(context, Icons.receipt_long, 'Pesanan Diproses', '08:15 AM', true, true),
          _timelineItem(context, Icons.content_cut, 'Sedang Dipotong & Dibersihkan', '08:30 AM • Standar Halal & Higienis', true, true),
          _timelineItem(context, Icons.local_shipping, 'Dalam Pengiriman', '09:10 AM • Kurir menuju lokasi Anda', true, false, isCurrent: true),
          _timelineItem(context, Icons.home, 'Sampai Tujuan', 'Estimasi 09:25 AM', false, false),
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

  Widget _buildPastOrder(BuildContext context, String date, String price, String title, String subtitle, String imgUrl, bool isPrimaryBtn) {
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)),
              ),
              const SizedBox(width: 16),
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
