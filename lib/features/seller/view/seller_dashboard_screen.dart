import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Penjual', style: Theme.of(context).textTheme.headlineMedium),
                    Text('Ringkasan toko Anda hari ini', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Mode Pembeli'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            Text('Pesanan Aktif', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildOrderCard(context, 'ORD-20231024-001', 'Budi Santoso', '10:30 WIB', 'Menunggu Konfirmasi', AppTheme.errorContainer, AppTheme.onErrorContainer, Icons.pending_actions, 'Ayam Broiler Utuh', '2 Ekor (Total ~2.4kg) • Potong 8', '76.000', 'https://lh3.googleusercontent.com/aida-public/AB6AXuA4F-m_2PY7tPb2g8y4zCSxpS1IQhO1FbEMPPU26R8BdZGIr5QinILwEoeLfJpkm6coB35ZS9_b5uf0K3RMGYxRciqJTFWxyNmLXifvSKr8-pBj4iDZwxku1Kyr1P0N5dOvCncShPHiwYiumRPIvJrwAJIzJJW4DUZNGRK9Hgh7Ni-9Dn2CUDEOpF27A8AImmMPJN5XzIKxE5U0ZfV4jJ7PN1LJy13XSkr_JLG4CRdR_41Q23DhBhQddaLaNKLJct2c9tpB8e7Kig', true),
            const SizedBox(height: 12),
            _buildOrderCard(context, 'ORD-20231024-002', 'Siti Aminah', '09:15 WIB', 'Perlu Dipotong', AppTheme.secondaryContainer, AppTheme.onSecondaryContainer, Icons.content_cut, 'Ayam Kampung', '1 Ekor (~0.9kg) • Potong 4', '65.000', null, false),
            const SizedBox(height: 24),
            Text('Kelola Stok Cepat', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildStockManager(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(context, 'Penjualan Hari Ini', 'Rp 1.25M', Icons.payments, AppTheme.primary, AppTheme.primaryContainer.withValues(alpha: 0.2)),
        _statCard(context, 'Order Masuk', '12', Icons.receipt_long, AppTheme.secondary, AppTheme.secondaryContainer.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String id, String name, String time, String status, Color statusBg, Color statusColor, IconData statusIcon, String productTitle, String productDesc, String price, String? imgUrl, bool showAcceptReject) {
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
                  Text(id, style: Theme.of(context).textTheme.labelLarge),
                  Text('$name • $time', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              if (imgUrl != null) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productTitle, style: Theme.of(context).textTheme.labelLarge),
                    Text(productDesc, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Rp $price', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (showAcceptReject)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Terima Pesanan'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Tolak')),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Proses Pemotongan'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceContainerHighest, foregroundColor: AppTheme.onSurface),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockManager(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jenis Ayam', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            initialValue: 'Ayam Broiler',
            items: ['Ayam Broiler', 'Ayam Kampung', 'Ayam Pejantan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 16),
          Text('Tambah Stok (Ekor)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              const Expanded(child: TextField(textAlign: TextAlign.center, decoration: InputDecoration(border: OutlineInputBorder()))),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Harga per Ekor / Kg', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          const TextField(decoration: InputDecoration(prefixText: 'Rp ', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Perbarui Stok'),
            ),
          ),
        ],
      ),
    );
  }
}
