import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/repository/auth_repository.dart';
import '../../auth/model/user_model.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {})],
      ),
      body: userDataAsync.when(
        data: (userData) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(context, userData, ref),
                    const SizedBox(height: 24),
                    _buildSettingsLinks(context, userData, ref),
                    const SizedBox(height: 24),
                    if (userData?.role == 'seller')
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? userData, WidgetRef ref) {
    final name = userData?.name ?? 'User';
    final email = userData?.email ?? '';
    final phone = userData?.phoneNumber ?? 'Belum diatur';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showEditPhotoDialog(context, userData, ref),
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceContainerLowest, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    image: DecorationImage(
                      image: NetworkImage(userData?.photoUrl != null && userData!.photoUrl.isNotEmpty
                          ? userData.photoUrl
                          : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlPRfB4riCZ2-0PkNOkW_ZGSyfzej1VAp13CTmKBPVAuH2K5rbm61uPekDOSLVqvYFEE6Hfjh7i5TCJXBQHEbXMafZbVv8kllXVeh6wu6ch2ysN89az98Pppb99-2SA1wtA-nncGcnqRQ8HkRf1HDugQegE5R4sQGMeCZ2evmR9VYfw8PrF__cOD5BcdaCDq8ZL2LBVZEsf7hrrNWUugDFbSov-CsuAnKMNO8bj-jTNX8RD0Nq4f-Vo8R3Yw5tK7y9Qak-EhaRVA'),
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
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('$email • $phone', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context, userData, ref),
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

  void _showEditPhotoDialog(BuildContext context, UserModel? userData, WidgetRef ref) {
    final photoController = TextEditingController(text: userData?.photoUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Foto Profil'),
        content: TextField(controller: photoController, decoration: const InputDecoration(labelText: 'URL Foto')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (userData != null) {
                await ref.read(authRepositoryProvider).updateUserData(userData.uid, {'photoUrl': photoController.text});
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(currentUserDataProvider);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel? userData, WidgetRef ref) {
    final nameController = TextEditingController(text: userData?.name);
    final phoneController = TextEditingController(text: userData?.phoneNumber);
    final addressController = TextEditingController(text: userData?.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Handphone')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (userData != null) {
                await ref.read(authRepositoryProvider).updateUserData(userData.uid, {
                  'name': nameController.text,
                  'phoneNumber': phoneController.text,
                  'address': addressController.text,
                });
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(currentUserDataProvider);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsLinks(BuildContext context, UserModel? userData, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _settingsLink(context, Icons.location_on, 'Alamat Saya', () => _showEditProfileDialog(context, userData, ref)),
          const Divider(height: 1, indent: 48),
          _settingsLink(context, Icons.payments, 'Metode Pembayaran', () => _showPaymentMethodsDialog(context, userData, ref)),
          const Divider(height: 1, indent: 48),
          _settingsLink(context, Icons.help_outline, 'Bantuan', () {}),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context, UserModel? userData, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Metode Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['QRIS', 'Transfer Bank', 'E-Wallet', 'COD'].map((method) => ListTile(
              leading: Icon(
                method == 'QRIS' ? Icons.qr_code_scanner :
                method == 'Transfer Bank' ? Icons.account_balance :
                method == 'E-Wallet' ? Icons.smartphone : Icons.local_shipping
              ),
              title: Text(method),
              trailing: Checkbox(
                value: userData?.paymentMethods.contains(method) ?? false,
                onChanged: (val) async {
                  if (userData != null) {
                    final current = List<String>.from(userData.paymentMethods);
                    if (val == true) {
                      current.add(method);
                    } else {
                      current.remove(method);
                    }
                    await ref.read(authRepositoryProvider).updateUserData(userData.uid, {'paymentMethods': current});
                    ref.invalidate(currentUserDataProvider);
                  }
                },
              ),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _settingsLink(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
        onPressed: () => context.go('/seller-dashboard'),
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
