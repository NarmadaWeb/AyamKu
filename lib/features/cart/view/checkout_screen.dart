import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../orders/repository/order_repository.dart';
import '../../orders/model/order.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            child: Column(
              children: [
                _buildAddress(context, ref),
                const SizedBox(height: 16),
                _buildDeliveryTime(context),
                const SizedBox(height: 16),
                _buildPaymentMethod(context),
                const SizedBox(height: 16),
                _buildOrderSummary(context),
              ],
            ),
          ),
          _buildBottomBar(context, ref),
        ],
      ),
    );
  }

  Widget _buildAddress(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authControllerProvider.notifier).getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final displayName = userData?.name ?? 'Budi Santoso';
        final phone = userData?.phoneNumber != null && userData!.phoneNumber.isNotEmpty ? userData.phoneNumber : '+62 812-3456-7890';
        final address = userData?.address != null && userData!.address.isNotEmpty ? userData.address : 'Jl. Merdeka No. 45, RT 01/RW 02, Kel. Sukamaju, Kec. Jatinegara, Jakarta Timur, 13310';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceContainerHighest)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text('Alamat Pengiriman', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
                    ],
                  ),
                  Text('Ubah', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: Theme.of(context).textTheme.labelLarge),
                    Text(phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(address, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.outlineVariant)),
                      child: Text('Rumah', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildDeliveryTime(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceContainerHighest)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Waktu Pengiriman', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _timeSlot(context, 'Pagi', '06:00 - 09:00', true)),
              const SizedBox(width: 8),
              Expanded(child: _timeSlot(context, 'Siang', '10:00 - 13:00', false)),
              const SizedBox(width: 8),
              Expanded(child: _timeSlot(context, 'Sore', '14:00 - 17:00', false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 4),
              Text('Pengiriman dijamin fresh sesuai slot waktu yang dipilih.', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeSlot(BuildContext context, String title, String time, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurface)),
          Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceContainerHighest)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Metode Pembayaran', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          _paymentOption(context, 'QRIS', Icons.qr_code_scanner, true),
          const SizedBox(height: 8),
          _paymentOption(context, 'Transfer Bank', Icons.account_balance, false),
          const SizedBox(height: 8),
          _paymentOption(context, 'E-Wallet', Icons.smartphone, false),
          const SizedBox(height: 8),
          _paymentOption(context, 'Bayar di Tempat (COD)', Icons.local_shipping, false, subtitle: 'Biaya penanganan Rp 2.000'),
        ],
      ),
    );
  }

  Widget _paymentOption(BuildContext context, String title, IconData icon, bool isSelected, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          Radio(value: isSelected, groupValue: isSelected, onChanged: (_) {}, activeColor: AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceContainerHighest)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Ringkasan Belanja', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal Produk', style: Theme.of(context).textTheme.bodyMedium), Text('Rp 175.000', style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Biaya Pengiriman', style: Theme.of(context).textTheme.bodyMedium), Text('Rp 15.000', style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Biaya Layanan', style: Theme.of(context).textTheme.bodyMedium), Text('Rp 2.000', style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
              Text('Rp 192.000', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Pembayaran', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                Text('Rp 192.000', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (user != null) {
                  final userData = await ref.read(authControllerProvider.notifier).getUserData();

                  final phone = userData?.phoneNumber != null && userData!.phoneNumber.isNotEmpty ? userData.phoneNumber : '+62 812-3456-7890';
                  final address = userData?.address != null && userData!.address.isNotEmpty ? userData.address : 'Jl. Merdeka No. 45';
                  final userName = userData?.name ?? user.displayName ?? 'User';

                  final order = OrderModel(
                    id: '',
                    userId: user.uid,
                    userName: userName,
                    userPhone: phone,
                    userAddress: address,
                    status: 'Menunggu Konfirmasi',
                    totalPrice: 192000,
                    items: ['1x Ayam Broiler Utuh', '1x Dada Ayam Fillet'],
                    createdAt: DateTime.now(),
                  );
                  await ref.read(orderRepositoryProvider).createOrder(order);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
                    context.go('/orders');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                children: [
                  Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
