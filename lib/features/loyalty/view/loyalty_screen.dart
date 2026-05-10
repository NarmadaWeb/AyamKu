import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCards(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tukar Poin Anda', style: Theme.of(context).textTheme.headlineSmall),
                TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
              ],
            ),
            const SizedBox(height: 8),
            _buildVouchers(context),
            const SizedBox(height: 32),
            Text('Riwayat Poin', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo SegarPoints', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('2,450', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 28)),
                    const SizedBox(width: 4),
                    Text('pts', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.info, size: 14, color: AppTheme.secondary),
                    const SizedBox(width: 4),
                    Text('Kedaluwarsa 31 Des 2024', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC7oZX721gsCRbDqsxuHLhIIPe0vwGY7V8EWv2VpHfbYotnhH9C2opm_Sq-vaw5vrc0Mf1_q7CW6qwnAzoc5NF0nP9yzg1svsbIwEHlUSQnr9_xjKZmOWKVjVFPOhN2g9Ep9Af5F8aKWQMcOcuHKPNXKdrzfGxbJOBb3MpdRoJXjCT7MHj-Z9Rg7ueeNIpwhuc1DUdHLOayuNSm9OF1z7W2VrQdus-bFEZrbKBg7_GKqsIut0XTMMWKhddFwLUJIQhbzCifom3jQw'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Membership', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Gold Member', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const Icon(Icons.workspace_premium, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVouchers(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _voucherCard(context, 'Diskon 20%', 'Voucher Potongan Ayam Utuh', '500 pts', AppTheme.secondary, 'https://lh3.googleusercontent.com/aida-public/AB6AXuC0SHedVoClginfxjfQtapEHG4p6RCURcdDa7UscKq8e9ap99ZewEVsfCAESCfWJzfzUwNCNYr0j-dxb0Lykqd1rk1dEZYbZykKawWiXuWqgl9gNm0G6CC3B_6xJiyZxXg7UichxTlXqf5oywY5d0ih7hqGJpRlDczwlIBQC6BbeJoHJXFFzeBIa-mGblTCd3yzwOemAsnlcf6FeV3IHwvJWjBHjSHPejnyXvrWZQDw1-yb9_vBoQK8qS2X31z0FIoONYrgvKT-oQ'),
          const SizedBox(width: 12),
          _voucherCard(context, 'Gratis Ongkir', 'Gratis Pengiriman Dingin', '300 pts', AppTheme.primary, 'https://lh3.googleusercontent.com/aida-public/AB6AXuAwmoBEDtkOkFQ3wChb_EKbMFCerrFegCr81lqWq0RyEDtl5SU-ZfgnlX9p9XC5Wea6m7Em5cor6rQ2u3R1CDLWkHqBroQI9Wdh9o9E43uWB0F94MFLfN4fSgJpt90CowG8GRu4pm7jOEknOP6-UHwn21iuE8GXtavy5F90K7eZXG-M8TxGRw-crrwB-HX-iVcEwRStNn38iOx4fxBdJb2nlsURkH6v8DbBh6s4Gn0gWlx57eY50eIARrQvziNzVFlGSpQddg0Ilw'),
        ],
      ),
    );
  }

  Widget _voucherCard(BuildContext context, String badge, String title, String pts, Color badgeColor, String imgUrl) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(100)),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pts, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(100)),
                      child: Text('Tukar', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onPrimaryContainer)),
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

  Widget _buildHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          _historyItem(context, 'Pesanan #ORD-9821', 'Hari ini, 10:45', '+120', true),
          const Divider(height: 1),
          _historyItem(context, 'Tukar Voucher Diskon', 'Kemarin, 14:20', '-500', false),
          const Divider(height: 1),
          _historyItem(context, 'Pesanan #ORD-8744', '12 Okt 2023', '+85', true),
        ],
      ),
    );
  }

  Widget _historyItem(BuildContext context, String title, String subtitle, String pts, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive ? AppTheme.secondaryContainer : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isPositive ? Icons.receipt_long : Icons.redeem, color: isPositive ? AppTheme.onSecondaryContainer : AppTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pts, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: isPositive ? AppTheme.secondary : AppTheme.error, fontSize: 16)),
              Text('pts', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
