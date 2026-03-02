import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Info-only screen about Khawi+ benefits.
/// To subscribe, users are directed to the canonical SubscriptionScreen.
class KhawiPlusScreen extends ConsumerWidget {
  const KhawiPlusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'خاوي بلس' : 'Khawi Plus'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isRtl
                ? 'عزز تأثيرك في المجتمع'
                : 'Boost your impact in the community',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? 'خاوي بلس يفتح لك مزايا إضافية مثل مضاعف النقاط واستبدال المكافآت.'
                : 'Khawi Plus unlocks bonus perks like XP multipliers and reward redemption.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _BenefitTile(
            icon: Icons.bolt,
            title: isRtl ? 'مضاعف النقاط 1.5×' : '1.5× XP Multiplier',
            subtitle: isRtl
                ? 'اكسب 50% نقاط إضافية في كل رحلة.'
                : 'Earn 50% more XP on every ride.',
          ),
          _BenefitTile(
            icon: Icons.card_giftcard,
            title: isRtl ? 'استبدال المكافآت' : 'Redeem Rewards',
            subtitle: isRtl
                ? 'استبدل نقاطك بمكافآت وأكواد حقيقية.'
                : 'Redeem XP for real rewards and codes.',
          ),
          _BenefitTile(
            icon: Icons.support_agent,
            title: isRtl ? 'دعم ذو أولوية' : 'Priority Support',
            subtitle: isRtl
                ? 'وصول على مدار الساعة لفريق السلامة.'
                : '24/7 access to our safety team.',
          ),
          const SizedBox(height: 24),

          // Status card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isPremium ? AppTheme.accentGold : AppTheme.borderColor,
                width: isPremium ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPremium ? Icons.verified : Icons.info_outline,
                        color: isPremium
                            ? AppTheme.accentGold
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPremium
                            ? (isRtl
                                ? 'خاوي بلس مفعّل ✓'
                                : 'Khawi Plus Active ✓')
                            : (isRtl ? 'غير مشترك' : 'Not Subscribed'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isPremium
                                      ? AppTheme.accentGold
                                      : AppTheme.textPrimary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPremium
                        ? (isRtl
                            ? 'استمتع بجميع مزايا الاشتراك.'
                            : 'Enjoy all subscription benefits.')
                        : (isRtl
                            ? 'اشترك لفتح جميع المزايا.'
                            : 'Subscribe to unlock all benefits.'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(Routes.subscription),
                        icon: const Icon(Icons.star),
                        label: Text(
                          isRtl
                              ? 'اشترك الآن - 30 ريال/شهر'
                              : 'Subscribe Now - 30 SAR/month',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentGold.withValues(alpha: 0.2),
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
