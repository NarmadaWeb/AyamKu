import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('Pusat Bantuan', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Halo! Ada yang bisa kami bantu hari ini?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari topik bantuan (mis. Pengembalian)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: const BorderSide(color: AppTheme.outlineVariant)),
              ),
            ),
            const SizedBox(height: 32),
            Align(alignment: Alignment.centerLeft, child: Text('Topik Populer', style: Theme.of(context).textTheme.labelLarge)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _topicCard(context, 'Pengiriman', Icons.local_shipping, AppTheme.secondaryContainer.withValues(alpha: 0.2), AppTheme.secondary),
                _topicCard(context, 'Kualitas Produk', Icons.verified, AppTheme.primary.withValues(alpha: 0.1), AppTheme.primary),
                _topicCard(context, 'Pembatalan', Icons.cancel, AppTheme.surfaceVariant, AppTheme.onSurfaceVariant),
                _topicCard(context, 'Akun Saya', Icons.account_circle, AppTheme.surfaceContainer.withValues(alpha: 0.2), AppTheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 32),
            _buildFAQ(context),
            const SizedBox(height: 32),
            _buildContact(context),
          ],
        ),
      ),
    );
  }

  Widget _topicCard(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppTheme.surfaceContainerHighest)),
            ),
            child: Text('Pertanyaan yang Sering Diajukan', style: Theme.of(context).textTheme.labelLarge),
          ),
          _faqItem(context, 'Berapa lama pesanan saya akan sampai?', 'Pesanan yang dilakukan sebelum pukul 14:00 akan dikirim pada hari yang sama. Estimasi pengiriman memakan waktu 1-3 jam tergantung jarak lokasi Anda.'),
          const Divider(height: 1),
          _faqItem(context, 'Bagaimana jika ayam yang diterima tidak segar?', 'Kami menjamin kesegaran 100%. Jika Anda menerima produk yang tidak memenuhi standar, harap hubungi Live Chat kami dalam 1 jam setelah menerima pesanan untuk proses retur/refund.'),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: Text('Lihat Semua FAQ', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary))),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(BuildContext context, String q, String a) {
    return ExpansionTile(
      title: Text(q, style: Theme.of(context).textTheme.bodyMedium),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(a, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _buildContact(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.chat, color: Colors.white)),
                const SizedBox(width: 8),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Live Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('2-5 menit', style: TextStyle(color: Colors.white70, fontSize: 10))])),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle), child: const Icon(Icons.call, color: AppTheme.onSecondaryContainer)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WhatsApp', style: TextStyle(color: AppTheme.onSecondaryContainer, fontWeight: FontWeight.bold)), Text('Bantuan detail', style: TextStyle(color: AppTheme.onSecondaryContainer, fontSize: 10))])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
