import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),
                  _buildSettingsLinks(context),
                  const SizedBox(height: 24),
                  _buildSellerModeAction(context),
                  const SizedBox(height: 32),
                  _buildLogoutAction(context, ref),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surfaceContainerLowest, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBlPRfB4riCZ2-0PkNOkW_ZGSyfzej1VAp13CTmKBPVAuH2K5rbm61uPekDOSLVqvYFEE6Hfjh7i5TCJXBQHEbXMafZbVv8kllXVeh6wu6ch2ysN89az98Pppb99-2SA1wtA-nncGcnqRQ8HkRf1HDugQegE5R4sQGMeCZ2evmR9VYfw8PrF__cOD5BcdaCDq8ZL2LBVZEsf7hrrNWUugDFbSov-CsuAnKMNO8bj-jTNX8RD0Nq4f-Vo8R3Yw5tK7y9Qak-EhaRVA'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: AppTheme.onPrimary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Budi Santoso', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('budi.santoso@email.com • +62 812-3456-7890', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_outline),
              label: const Text('Edit Profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsLinks(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _settingsLink(context, Icons.location_on, 'Alamat Saya'),
          const Divider(height: 1, indent: 48),
          _settingsLink(context, Icons.payments, 'Metode Pembayaran'),
          const Divider(height: 1, indent: 48),
          _settingsLink(context, Icons.help_outline, 'Bantuan'),
        ],
      ),
    );
  }

  Widget _settingsLink(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 16),
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerModeAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.storefront, color: AppTheme.secondary),
        label: Text('Switch to Seller Mode', style: Theme.of(context).textTheme.labelLarge),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppTheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.surfaceContainer,
        ),
      ),
    );
  }

  Widget _buildLogoutAction(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () {
        ref.read(authControllerProvider.notifier).signOut();
      },
      icon: const Icon(Icons.logout, color: AppTheme.error),
      label: Text('Keluar', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.error)),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
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
            case 3: context.go('/orders'); break;
            case 4: break;
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
