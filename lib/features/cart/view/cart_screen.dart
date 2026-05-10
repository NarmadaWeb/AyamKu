import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Keranjang Anda', style: Theme.of(context).textTheme.headlineMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(100)),
                        child: Text('2 Item', style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _cartItem(
                    context,
                    'Ayam Broiler Utuh', '1.2 kg • Potong 8', '45.000', '1',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCrRXdLwMqI3qfJUg3Hbz840RXblEoV-LFemORN5LY7S-wX2AhLMJ3PZ-2ofq02wDg-uZfHo55DxS4iFD0xudw17crB3fWUxhLEXIS_NY8f33gh971sImPCwVohnrLSSvgFU8N7AhkV0Bifta4DcLRyfpgVkqNlUGSG_BLjXL4Nj_w20UYaENbRq1tCpVSrxZhT6yxJ8ZFnbQYaS7zNbM9Ceq4JW7GCLx4G_0FP7gzna9AQj7oKdCrOH-rtLVWBY6albGvFOTN-FQ'
                  ),
                  const SizedBox(height: 12),
                  _cartItem(
                    context,
                    'Dada Ayam Fillet', '500g • Tanpa Kulit', '32.500', '2',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBxO6vtzyCwPcXkcVex6gBYe4fJhzFdetgxUMKkAH-_ZxnMeRIZfmWoeNizSHt6Iuj2ypI7AaMYh2IWbnlGcKAmVZPEISDLHvdB6RaQarvpBp0x1CmXFyOmY83jxw1BqnMy_ZlY8cFs-TDYV3y1OYnD8oKFOw9ieutARtfUvosXptj3Jck6_KZNJY1_CatUs_NfO443ydrT1OE6y86pJoBSCjaOkejElyqreui_quiWA60RJU9ZCQbaLjneTyj9tq2lheBDArn8Gg'
                  ),
                  const SizedBox(height: 24),
                  _buildSummary(context),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lanjut ke Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _cartItem(BuildContext context, String title, String subtitle, String price, String qty, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
                    const Icon(Icons.close, color: AppTheme.onSurfaceVariant, size: 20),
                  ],
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp $price', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        children: [
                          const Icon(Icons.remove, size: 16, color: AppTheme.onSurfaceVariant),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, size: 16, color: AppTheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Pesanan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Harga (3 Barang)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              Text('Rp 110.000', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 4),
                  Text('Estimasi Ongkos Kirim', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
              Text('Rp 15.000', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tagihan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18)),
              Text('Rp 125.000', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppTheme.primary)),
            ],
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
        currentIndex: 2,
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
            case 2: break;
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
