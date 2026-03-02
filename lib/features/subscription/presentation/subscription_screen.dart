import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(
          isRtl ? 'خاوي بريميوم' : 'Khawi Premium',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.shadowMedium,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.accentGold,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRtl
                        ? 'أطلق العنان لإمكانياتك الكاملة'
                        : 'Unlock Full Potential',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRtl
                        ? 'انضم لأكثر من 10 آلاف مستخدم يوفرون أكثر مع بريميوم'
                        : 'Join 10k+ users saving more with Premium',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureTile(
              context,
              Icons.card_giftcard,
              isRtl ? 'استبدال المكافآت' : 'Redeem Rewards',
              isRtl
                  ? 'استبدل نقاط XP بمكافآت وأكواد حقيقية.'
                  : 'Redeem XP for real rewards and promo codes.',
              isRtl,
            ),
            _buildFeatureTile(
              context,
              Icons.trending_up,
              isRtl ? 'مضاعف XP ×1.5' : '1.5× XP Multiplier',
              isRtl
                  ? 'اكسب 50% نقاط إضافية في كل رحلة.'
                  : 'Earn 50% more XP on every single ride.',
              isRtl,
            ),
            _buildFeatureTile(
              context,
              Icons.support_agent,
              isRtl ? 'دعم ذو أولوية' : 'Priority Support',
              isRtl
                  ? 'وصول على مدار الساعة لفريق السلامة.'
                  : '24/7 access to our dedicated safety team.',
              isRtl,
            ),
            _buildFeatureTile(
              context,
              Icons.star_border,
              isRtl ? 'شارات حصرية' : 'Exclusive Badges',
              isRtl
                  ? 'أظهر شارتك الذهبية المميزة.'
                  : 'Show off your golden profile status.',
              isRtl,
            ),
            const SizedBox(height: 40),
            _buildPlanCard(
              context,
              isRtl ? 'شهري' : 'Monthly',
              isRtl ? '30 ريال' : '30 SAR',
              isRtl ? 'إلغاء في أي وقت' : 'Cancel anytime',
              isRtl,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              isRtl ? 'سنوي' : 'Annual',
              isRtl ? '250 ريال' : '250 SAR',
              isRtl ? 'وفر 30% سنوياً' : 'Save 30% yearly',
              isRtl,
              isPopular: true,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _startSubscription(context, ref, isRtl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isRtl
                      ? 'ابدأ تجربة مجانية لمدة 7 أيام'
                      : 'Start 7-Day Free Trial',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRtl
                  ? 'دفع آمن عبر Apple Pay و مدى'
                  : 'Secure payment via Apple Pay & Mada',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    bool isRtl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary, height: 1.3),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String title,
    String price,
    String sub,
    bool isRtl, {
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular
            ? AppTheme.primaryGreen.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isPopular ? AppTheme.primaryGreen : AppTheme.borderColor,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                isRtl ? 'الأفضل' : 'Best',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  sub,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _startSubscription(
    BuildContext context,
    WidgetRef ref,
    bool isRtl,
  ) async {
    const String monthlyPriceId =
        'price_monthly_id_placeholder'; // Replace with real Stripe Price ID
    final uid = ref.read(userIdProvider);
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isRtl ? 'يرجى تسجيل الدخول أولاً' : 'Please login first'),
        ),
      );
      return;
    }

    // Show loading
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );

    try {
      // Create checkout session via repository
      final repo = ref.read(subscriptionRepoProvider);
      final checkoutUrl = await repo.createCheckoutSession(monthlyPriceId);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      if (checkoutUrl != null) {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch checkout URL');
        }
      } else {
        throw Exception('Failed to create checkout session');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRtl ? 'حدث خطأ: $e' : 'Error: $e')),
        );
      }
    }
  }
}
