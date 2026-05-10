import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('Dada Ayam Fillet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(context),
                _buildProductInfo(context),
              ],
            ),
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD45Bc7hMmtc5yl5b2o0ROjwl274BytiIaXeA8u4gT-oM0wGV6VbeH065dCoYINotavw1CbHr8nHFnC8jzYCTajvB7Lcz9YkahfT9stiqfn0UeNwEVIyQLwQyLL7HuSikDFeGcG0UHGi9x0AEfjfYljqGxCFE7yYtzY2r0KR7yQLXJuqhd4IBlh1ALJtkxz1qoIAKD33HtAl7V5GQn_qjIbYmewQDdpD12ihYBs9UR9vZksDZcAWEcY2syUi_cd_j8rs-l6mpUzbQ',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _badge(Icons.today, 'Fresh Today', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
              const SizedBox(height: 8),
              _badge(Icons.ac_unit, 'Freezer Free', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
              const SizedBox(height: 8),
              _badge(Icons.verified, 'Halal', const Color(0xFFe8f5e9), const Color(0xFF2e7d32), const Color(0xFFc8e6c9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String text, Color bg, Color color, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dada Ayam Fillet Premium', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Daging dada ayam tanpa tulang dan kulit. Bersih, higienis, dan siap olah untuk berbagai hidangan keluarga.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rp 45.000', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/ 1 kg', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pilih Berat', style: Theme.of(context).textTheme.labelLarge),
              Text('Total: Rp 45.000', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _weightOption('0.8 kg', false),
              _weightOption('1 kg', true),
              _weightOption('1.2 kg', false),
              _weightOption('1.5 kg', false),
              _weightOption('2 kg', false),
            ],
          ),
          const SizedBox(height: 24),

          Text('Pilihan Potongan', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _cutOption('Utuh', true),
              _cutOption('Dada', false),
              _cutOption('Paha Atas', false),
              _cutOption('Paha Bawah', false),
              _cutOption('Sayap', false),
              _cutOption('Ceker', false),
            ],
          ),
          const SizedBox(height: 24),

          Text('Potong Sesuai Permintaan (Opsional)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Contoh: Potong dadu kecil untuk sate...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outline),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cutOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) {},
            activeColor: AppTheme.primary,
          ),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.outline),
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                  const Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add, color: AppTheme.primary), onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Tambah ke Keranjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63939),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
