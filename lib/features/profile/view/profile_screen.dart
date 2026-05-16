import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../home/repository/notification_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialogs.dart';
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
                    const SizedBox(height: 32),
                    if (userData?.role == 'seller') ...[
                      _buildSellerModeAction(context),
                      const SizedBox(height: 16),
                    ],
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
                          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
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
    if (userData == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                try {
                  final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (image != null) {
                    final file = File(image.path);
                    if (await file.length() > 2 * 1024 * 1024) {
                      if (context.mounted) {
                        AppDialogs.showErrorDialog(
                          context: context,
                          title: 'Gambar Terlalu Besar',
                          message: 'Ukuran gambar maksimal adalah 2MB.',
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      _uploadImage(context, ref, userData.uid, file);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppDialogs.showErrorDialog(
                      context: context,
                      title: 'Gagal',
                      message: 'Gagal memilih gambar: $e',
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                try {
                  final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    final file = File(image.path);
                    if (await file.length() > 2 * 1024 * 1024) {
                      if (context.mounted) {
                        AppDialogs.showErrorDialog(
                          context: context,
                          title: 'Gambar Terlalu Besar',
                          message: 'Ukuran gambar maksimal adalah 2MB.',
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      _uploadImage(context, ref, userData.uid, file);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppDialogs.showErrorDialog(
                      context: context,
                      title: 'Gagal',
                      message: 'Gagal mengambil foto: $e',
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(BuildContext context, WidgetRef ref, String uid, File file) async {
    // Show loading indicator

    // Using a separate context for the dialog to ensure we can pop it safely
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mengunggah foto...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final url = await ref.read(authRepositoryProvider).uploadProfileImage(uid, file);
      await ref.read(authRepositoryProvider).updateUserData(uid, {'photoUrl': url});

      if (context.mounted) {
        // Pop the dialog using the root navigator to ensure it's the dialog being popped
        Navigator.of(context, rootNavigator: true).pop();
        AppDialogs.showSuccessDialog(
          context: context,
          title: 'Berhasil',
          message: 'Foto profil berhasil diperbarui',
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      if (context.mounted) {
        // Pop the dialog
        Navigator.of(context, rootNavigator: true).pop();
        AppDialogs.showErrorDialog(
          context: context,
          title: 'Gagal',
          message: 'Gagal mengunggah foto: ${e.toString()}',
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, UserModel? userData, WidgetRef ref) {
    final nameController = TextEditingController(text: userData?.name);
    final phoneController = TextEditingController(text: userData?.phoneNumber);
    final addressController = TextEditingController(text: userData?.address);
    double? latitude = userData?.latitude;
    double? longitude = userData?.longitude;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Handphone')),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    hintText: 'Masukkan alamat atau gunakan GPS',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      LocationPermission permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }

                      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                        final position = await Geolocator.getCurrentPosition();
                        latitude = position.latitude;
                        longitude = position.longitude;

                        List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
                        if (placemarks.isNotEmpty) {
                          Placemark place = placemarks.first;
                          addressController.text = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.postalCode}";
                        }

                        AppDialogs.showSuccessDialog(
                          context: context,
                          title: 'Berhasil',
                          message: 'Lokasi berhasil didapatkan',
                        );
                      }
                    } catch (e) {
                      AppDialogs.showErrorDialog(
                        context: context,
                        title: 'Gagal',
                        message: 'Gagal mendapatkan lokasi: $e',
                      );
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Gunakan Lokasi Saat Ini'),
                ),
                if (latitude != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 8),
                     child: Text('Kordinat: $latitude, $longitude', style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
                   ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (userData != null) {
                  try {
                    await ref.read(authRepositoryProvider).updateUserData(userData.uid, {
                      'name': nameController.text,
                      'phoneNumber': phoneController.text,
                      'address': addressController.text,
                      'latitude': latitude,
                      'longitude': longitude,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      AppDialogs.showSuccessDialog(
                        context: context,
                        title: 'Berhasil',
                        message: 'Profil berhasil diperbarui',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppDialogs.showErrorDialog(
                        context: context,
                        title: 'Gagal',
                        message: 'Gagal memperbarui profil: $e',
                      );
                    }
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
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
          _settingsLink(context, Icons.help_outline, 'Bantuan', () => context.push('/help')),
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
                    try {
                      final current = List<String>.from(userData.paymentMethods);
                      if (val == true) {
                        current.add(method);
                      } else {
                        current.remove(method);
                      }
                      await ref.read(authRepositoryProvider).updateUserData(userData.uid, {'paymentMethods': current});
                      if (context.mounted) {
                        AppDialogs.showSuccessDialog(
                          context: context,
                          title: 'Berhasil',
                          message: 'Metode pembayaran $method ${val == true ? 'ditambahkan' : 'dihapus'}',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppDialogs.showErrorDialog(
                          context: context,
                          title: 'Gagal',
                          message: 'Gagal memperbarui metode pembayaran: $e',
                        );
                      }
                    }
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
      child: ElevatedButton.icon(
        onPressed: () => context.go('/seller-dashboard'),
        icon: const Icon(Icons.storefront, color: Colors.white),
        label: Text('Kembali ke Dashboard Penjual', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
