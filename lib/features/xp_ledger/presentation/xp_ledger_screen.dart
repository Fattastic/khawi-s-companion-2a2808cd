import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/xp_ledger/data/xp_ledger_repo.dart';
import 'package:khawi_flutter/core/widgets/app_shimmer.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';

/// XP Ledger screen.
/// Shows XP transaction history. Redeem requires Khawi+ subscription.
class XpLedgerScreen extends ConsumerWidget {
  const XpLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(l10n.xpLedgerTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KhawiMotion.slideUpFadeIn(
                _buildBalanceCard(context, profile, isRtl, l10n),
                index: 0,
              ),
              const SizedBox(height: 24),
              KhawiMotion.slideUpFadeIn(
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(Routes.sharedLeaderboard),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: Text(
                          isRtl ? 'المتصدرين' : 'Leaderboard',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(Routes.sharedPromoCodes),
                        icon: const Icon(Icons.local_offer_outlined),
                        label: Text(
                          isRtl ? 'أكواد الخصم' : 'Promo Codes',
                        ),
                      ),
                    ),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 12),
              KhawiMotion.slideUpFadeIn(
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Routes.sharedCarbon),
                    icon: const Icon(Icons.eco_outlined),
                    label: Text(
                      isRtl ? 'الأثر البيئي' : 'Carbon Tracker',
                    ),
                  ),
                ),
                index: 2,
              ),
              const SizedBox(height: 16),
              KhawiMotion.slideUpFadeIn(
                _buildRedeemSection(context, profile, isRtl, l10n),
                index: 3,
              ),
              const SizedBox(height: 32),
              KhawiMotion.slideUpFadeIn(
                Text(
                  l10n.xpLedgerHistory,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                index: 4,
              ),
              const SizedBox(height: 16),
              KhawiMotion.slideUpFadeIn(
                _buildTransactionList(context, ref, l10n, isRtl),
                index: 5,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.somethingWentWrong,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(myProfileProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    Profile profile,
    bool isRtl,
    AppLocalizations l10n,
  ) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryGreen, AppTheme.accentGold],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.redeemableXpLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
              ),
              const Spacer(),
              if (profile.isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Khawi+',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: profile.redeemableXp.toDouble(),
                ),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    '${value.round()}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'XP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.stars_rounded, color: Colors.white24, size: 48),
            ],
          ),
          if (profile.isPremium) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    l10n.xpLedgerMultiplierActive('1.5'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedeemSection(
    BuildContext context,
    Profile profile,
    bool isRtl,
    AppLocalizations l10n,
  ) {
    if (!profile.isPremium) {
      // Show Khawi+ upsell
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Text(
                  l10n.khawiPlusRequired,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.xpLedgerUpsellBody(l10n.khawiPlusMonthlyPrice),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBenefit(
                  context,
                  Icons.redeem,
                  l10n.redeemXp,
                ),
                const SizedBox(width: 16),
                _buildBenefit(
                  context,
                  Icons.qr_code,
                  l10n.promoCodes,
                ),
                const SizedBox(width: 16),
                _buildBenefit(
                  context,
                  Icons.trending_up,
                  l10n.xpLedgerMultiplierShort('1.5'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(Routes.subscription),
                icon: const Icon(Icons.star),
                label: Text(l10n.subscribeToKhawiPlus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Khawi+ active - show redeem button
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(Routes.sharedRedeem),
        icon: const Icon(Icons.redeem),
        label: Text(l10n.redeemXp),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isRtl,
  ) {
    final transactionsAsync = ref.watch(xpTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return AppEmptyState(
            icon: Icons.history,
            title: l10n.xpLedgerNoActivityYet,
            subtitle: l10n.xpLedgerEarnXpHint,
            isRtl: isRtl,
            ctaLabel: isRtl ? 'استكشاف التحديات' : 'Explore Challenges',
            onCta: () => context.push(Routes.sharedChallenges),
          );
        }
        return Column(
          children: transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final tx = entry.value;
            return KhawiMotion.slideUpFadeIn(
              _TransactionItem(
                key: ValueKey('xp_txn_${tx.id}'),
                title: tx.title,
                date: tx.createdAt.toString().split(' ')[0],
                amount: tx.amount,
                isDebit: tx.type == 'debit',
              ),
              index: index,
            );
          }).toList(),
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => const AppShimmer.listTile(),
      ),
      error: (err, _) => Text('${l10n.errorLoadingHistory}: $err'),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isDebit;

  const _TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isDebit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDebit ? Colors.red[50] : Colors.green[50],
            child: Icon(
              isDebit ? Icons.remove : Icons.add,
              color: isDebit ? Colors.red : Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  date,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            isDebit ? '-$amount' : '+$amount',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDebit ? Colors.red[700] : AppTheme.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }
}
