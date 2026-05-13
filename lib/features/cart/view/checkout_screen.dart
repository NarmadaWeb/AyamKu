import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../model/cart_item_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../orders/repository/order_repository.dart';
import '../../orders/model/order.dart';
import '../../auth/model/user_model.dart';
import '../repository/cart_repository.dart';
import 'package:intl/intl.dart';
import '../../orders/repository/midtrans_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends HookConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final cartItemsAsync = ref.watch(cartItemsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    final selectedTimeSlot = useState('06:00 - 09:00');
    final selectedPaymentMethod = useState('QRIS');

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: userDataAsync.when(
        data: (userData) => cartItemsAsync.when(
          data: (items) {
            if (items.isEmpty) return const Center(child: Text('Keranjang kosong'));

            final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
            final shipping = 15000.0;
            final serviceFee = 2000.0;
            final total = subtotal + shipping + serviceFee;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  child: Column(
                    children: [
                      _buildAddress(context, userData),
                      const SizedBox(height: 16),
                      _buildDeliveryTime(context, selectedTimeSlot),
                      const SizedBox(height: 16),
                      _buildPaymentMethod(context, selectedPaymentMethod),
                      const SizedBox(height: 16),
                      _buildOrderItems(context, ref, items, currencyFormat),
                      const SizedBox(height: 16),
                      _buildOrderSummary(context, subtotal, shipping, serviceFee, total, currencyFormat),
                    ],
                  ),
                ),
                _buildBottomBar(context, ref, userData, items, total, selectedTimeSlot.value, selectedPaymentMethod.value, currencyFormat),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAddress(BuildContext context, UserModel? userData) {
    final displayName = userData?.name ?? 'User';
    final phone = userData?.phoneNumber ?? '+62';
    final address = userData?.address ?? 'Alamat belum diatur';

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
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Text('Ubah', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
              ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTime(BuildContext context, ValueNotifier<String> selectedTimeSlot) {
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
              Expanded(child: _timeSlot(context, 'Pagi', '06:00 - 09:00', selectedTimeSlot)),
              const SizedBox(width: 8),
              Expanded(child: _timeSlot(context, 'Siang', '10:00 - 13:00', selectedTimeSlot)),
              const SizedBox(width: 8),
              Expanded(child: _timeSlot(context, 'Sore', '14:00 - 17:00', selectedTimeSlot)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeSlot(BuildContext context, String title, String time, ValueNotifier<String> selectedTimeSlot) {
    final isSelected = selectedTimeSlot.value == time;
    return GestureDetector(
      onTap: () => selectedTimeSlot.value = time,
      child: Container(
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
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, ValueNotifier<String> selectedPaymentMethod) {
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
          _paymentOption(context, 'QRIS', Icons.qr_code_scanner, selectedPaymentMethod),
          const SizedBox(height: 8),
          _paymentOption(context, 'Transfer Bank', Icons.account_balance, selectedPaymentMethod),
          const SizedBox(height: 8),
          _paymentOption(context, 'E-Wallet', Icons.smartphone, selectedPaymentMethod),
          const SizedBox(height: 8),
          _paymentOption(context, 'Bayar di Tempat (COD)', Icons.local_shipping, selectedPaymentMethod, subtitle: 'Biaya penanganan Rp 2.000'),
        ],
      ),
    );
  }

  Widget _paymentOption(BuildContext context, String title, IconData icon, ValueNotifier<String> selectedPaymentMethod, {String? subtitle}) {
    final isSelected = selectedPaymentMethod.value == title;
    return GestureDetector(
      onTap: () {
        selectedPaymentMethod.value = title;
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.labelLarge),
                        if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: selectedPaymentMethod.value,
              onChanged: (v) {
                if (v != null) selectedPaymentMethod.value = v;
              },
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, WidgetRef ref, List<CartItemModel> items, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.surfaceContainerHighest)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Daftar Produk', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: Theme.of(context).textTheme.labelLarge),
                      Text('${item.quantity}x • ${item.weight}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currencyFormat.format(item.price * item.quantity), style: Theme.of(context).textTheme.labelLarge),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                      onPressed: () => ref.read(cartRepositoryProvider).removeFromCart(item.id),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, double subtotal, double shipping, double serviceFee, double total, NumberFormat currencyFormat) {
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
          _summaryRow(context, 'Subtotal Produk', currencyFormat.format(subtotal)),
          _summaryRow(context, 'Biaya Pengiriman', currencyFormat.format(shipping)),
          _summaryRow(context, 'Biaya Layanan', currencyFormat.format(serviceFee)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
              Text(currencyFormat.format(total), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, UserModel? userData, List<CartItemModel> items, double total, String timeSlot, String payment, NumberFormat currencyFormat) {
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
                Text(currencyFormat.format(total), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (userData == null) return;

                // Show processing dialog
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
                            Text('Memproses Pesanan...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  final initialOrder = OrderModel(
                    id: '',
                    userId: userData.uid,
                    userName: userData.name,
                    userPhone: userData.phoneNumber,
                    userAddress: userData.address,
                    status: 'Menunggu Konfirmasi',
                    totalPrice: total,
                    items: items.map((e) => '${e.quantity}x ${e.name}').toList(),
                    createdAt: DateTime.now(),
                    deliveryTimeSlot: timeSlot,
                    paymentMethod: payment,
                    paymentStatus: 'pending',
                    latitude: userData.latitude,
                    longitude: userData.longitude,
                  );

                  final orderId = await ref.read(orderRepositoryProvider).createOrder(initialOrder);

                  // Decrement Stock
                  for (final item in items) {
                    await ref.read(orderRepositoryProvider).decrementStock(item.productId, item.quantity);
                  }

                  if (payment != 'Bayar di Tempat (COD)') {
                    final uniqueOrderId = '${orderId}_${DateTime.now().millisecondsSinceEpoch}';
                    final midtransResponse = await ref.read(midtransServiceProvider).createTransaction(
                      orderId: uniqueOrderId,
                      grossAmount: total,
                      customerName: userData.name,
                      customerEmail: userData.email,
                      customerPhone: userData.phoneNumber,
                    );

                    final snapToken = midtransResponse['token'];
                    final redirectUrl = midtransResponse['redirect_url'];

                    await ref.read(orderRepositoryProvider).updateOrder(orderId, {
                      'snapToken': snapToken,
                      'midtransOrderId': uniqueOrderId,
                    });

                    await ref.read(cartRepositoryProvider).clearCart();

                    if (context.mounted) {
                      Navigator.pop(context); // Close processing dialog
                      context.push('/payment', extra: redirectUrl);
                    }
                  } else {
                    await ref.read(cartRepositoryProvider).clearCart();
                    if (context.mounted) {
                      Navigator.pop(context); // Close processing dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green),
                      );
                      context.go('/orders');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close processing dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memproses pesanan: $e'), backgroundColor: AppTheme.error),
                    );
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
