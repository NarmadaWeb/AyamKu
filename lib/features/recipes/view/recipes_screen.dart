import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('AyamSegar', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _tag('Semua Resep', true),
                  const SizedBox(width: 8),
                  _tag('Berkuah', false),
                  const SizedBox(width: 8),
                  _tag('Goreng', false),
                  const SizedBox(width: 8),
                  _tag('Bakar', false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeroRecipe(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildSmallRecipe(context, 'Ayam Goreng Kalasan', 'Manis gurih meresap.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxx_sq-URyesezuZXZfMfisV5tTZW8e9O0uhP75mxgA8mZhVZC_174qQqINRgRb3rsrF0zACVPBvUTyfwzwRS1lv08FvqyKIrbMkYpAN9U5hZT2WKi30iTS2lnl2HT93rKFi82kz6ZrX8HDoJiiS5778yJsdsYESR7wfZ98BnmFNL0qTBgDALW2XIvukaAZIwTLqzB7WSLqQQQxt07slDH4sClrap-E-dDYcRd3cDui-6j3HbC96wUft4R5JV7ji-JGZfR_KV5Lw')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSmallRecipe(context, 'Ayam Bakar Madu', 'Karamelisasi sempurna.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAo40iKxL1HSCzM28lKxSgLIOqIK4GrEOHau4XhTbWh3clJTnaiX2_-mIpNFBepoCna0dCcuyKeURczgDWx5HNG7EGOFrWy980mN5vJr3CwHR31J9iJMNpKpcmdF6_3Cqzn7qd12Cb1yalZEGIkFIC3C8qp0um9K1UUkTA_rO7MNv2RDtzQclnNx_6MQ4cvtqdgjlNrLVyo-rkGFFHsuWmUw7omLN5GbSffJezrbqtqOsHJB5EeeKzvxzaw0K-k63GDtQ1Bof28rA')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppTheme.secondaryContainer, shape: BoxShape.circle),
                          child: const Icon(Icons.verified_user, color: AppTheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dijamin Segar & Higienis', style: Theme.of(context).textTheme.labelLarge),
                              Text('Semua resep menggunakan standar kualitas AyamSegar.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outlineVariant),
      ),
      child: Text(text, style: TextStyle(color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHeroRecipe(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuBL3iZ1B4z6GRnkeaXgm5-MhxFJGcHnL0E-ExpTvTZqrUyftAkNVpMLyZNxzhVouDvpqkCZYLCQoW371gv5SQO3WczoRaM0tQ9iKIRigwNsYO5rNXAPk1PqCISvXPvQ4UtvhYivmG9tvMQDiU0kYA-oXciTGxgo7JrEE3SJI9LLvtHi1f3BMmRPGlEpa-pi08ppHD7yPXy_gKvAqs1vjMbkf-0q2GwnbpC9badDo6n5Gtjx-8oV76GsMD9Q5vdOkkpdL8U0U-ulMA', height: 200, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: AppTheme.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text('Populer', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondaryContainer)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Opor Ayam Spesial Lebaran', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Resep klasik keluarga dengan kuah santan kental yang gurih.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('45 Min', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    const Icon(Icons.restaurant, size: 16, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('4 Porsi', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Beli Semua Bahan'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallRecipe(BuildContext context, String title, String subtitle, String imgUrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(imgUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge, maxLines: 2),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Beli'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
