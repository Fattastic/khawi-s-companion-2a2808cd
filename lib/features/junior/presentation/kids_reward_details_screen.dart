import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Detail screen for a specific kids reward item.
class KidsRewardDetailsScreen extends ConsumerWidget {
  const KidsRewardDetailsScreen({super.key, required this.rewardId});

  final String rewardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    // Mock reward data (replace with provider)
    final reward = _getMockReward(rewardId);

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.rewardDetails ?? 'Reward Details'),
        backgroundColor: AppTheme.backgroundGreen,
      ),
      body: reward == null
          ? const Center(child: Text('Reward not found'))
          : profileAsync.when(
              data: (profile) =>
                  _buildContent(context, ref, reward, profile.isPremium),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> reward,
    bool isPremium,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  reward['color'] as Color,
                  (reward['color'] as Color).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                reward['icon'] as IconData,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  reward['title'] as String,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // XP Cost
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward['xpCost']} XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (reward['category'] != null)
                      Chip(
                        label: Text(reward['category'] as String),
                        backgroundColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.1),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Premium Gate
                if (!isPremium) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              isRtl ? 'يتطلب Khawi+' : 'Khawi+ Required',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRtl
                              ? 'اشترك في Khawi+ لاستبدال نقاطك بمكافآت.'
                              : 'Subscribe to Khawi+ to redeem your XP for rewards.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push(Routes.subscription),
                          icon: const Icon(
                            Icons.star,
                            color: AppTheme.accentGold,
                          ),
                          label: Text(
                            isRtl ? 'ترقية إلى Khawi+' : 'Upgrade to Khawi+',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Description
                Text(
                  isRtl ? 'الوصف' : 'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),

                // How to Redeem
                Text(
                  isRtl ? 'كيفية الاستبدال' : 'How to Redeem',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildStep(
                  context,
                  '1',
                  isRtl
                      ? 'أكمل المزيد من الرحلات لكسب XP'
                      : 'Complete more rides to earn XP',
                ),
                _buildStep(
                  context,
                  '2',
                  isRtl
                      ? 'اضغط على زر الاستبدال أدناه'
                      : 'Tap the redeem button below',
                ),
                _buildStep(
                  context,
                  '3',
                  isRtl
                      ? 'أظهر رمز QR للحصول على مكافأتك'
                      : 'Show the QR code to claim your reward',
                ),
                const SizedBox(height: 32),

                // Redeem Button - Disabled if not premium
                if (isPremium)
                  FilledButton.icon(
                    onPressed: () => _handleRedeem(context, isRtl),
                    icon: const Icon(Icons.redeem),
                    label: Text(isRtl ? 'استبدال الآن' : 'Redeem Now'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => context.push(Routes.subscription),
                    icon: const Icon(Icons.lock),
                    label: Text(
                      isRtl
                          ? 'اشترك في Khawi+ للاستبدال'
                          : 'Subscribe to Khawi+ to Redeem',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ),
                const SizedBox(height: 12),

                // Terms
                Center(
                  child: Text(
                    isRtl ? 'تطبق الشروط والأحكام' : 'Terms & conditions apply',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedeem(BuildContext context, bool isRtl) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              isRtl ? 'تم طلب الاستبدال!' : 'Redemption Requested!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'يجب على ولي الأمر الموافقة على هذا الاستبدال.'
                  : 'A parent or guardian must approve this redemption.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: Text(isRtl ? 'تم' : 'Done'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getMockReward(String id) {
    final rewards = {
      '1': {
        'title': 'Ice Cream Treat',
        'description':
            'Get a free ice cream cone from participating stores. Perfect for a hot day after school!',
        'xpCost': 100,
        'icon': Icons.icecream,
        'color': Colors.pink,
        'category': 'Treats',
      },
      '2': {
        'title': 'Movie Ticket',
        'description':
            'One free child ticket to any movie at participating cinemas. Popcorn not included.',
        'xpCost': 500,
        'icon': Icons.movie,
        'color': Colors.purple,
        'category': 'Entertainment',
      },
      '3': {
        'title': 'Toy Store Voucher',
        'description':
            '50 SAR voucher for any toy store. Let your imagination run wild!',
        'xpCost': 1000,
        'icon': Icons.toys,
        'color': Colors.orange,
        'category': 'Shopping',
      },
    };
    return rewards[id];
  }
}
