import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/xp_ledger/data/xp_ledger_repo.dart';

/// Alternate XP Ledger screen with simple layout.
class XpLedgerAltScreen extends ConsumerWidget {
  const XpLedgerAltScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final l10n = AppLocalizations.of(context)!;

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
              _buildBalanceCard(context, profile, l10n),
              const SizedBox(height: 32),
              _buildQuickActions(context, profile.isPremium, l10n),
              const SizedBox(height: 32),
              Text(
                l10n.xpLedgerRecentActivity,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _buildTransactionList(ref, l10n),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('${l10n.somethingWentWrong}: $err')),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    Profile profile,
    AppLocalizations l10n,
  ) {
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
          Text(
            l10n.redeemableXpLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${profile.redeemableXp}",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.xpLedgerApproxValue(
                (profile.redeemableXp / 100).toStringAsFixed(2),
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isPremium,
    AppLocalizations l10n,
  ) {
    if (isPremium) {
      return SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => context.push(Routes.sharedRedeem),
          icon: const Icon(Icons.redeem),
          label: Text(l10n.redeemXp),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      );
    }

    // Non-premium: show subscription CTA
    return Column(
      children: [
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push(Routes.subscription),
            icon: const Icon(Icons.lock),
            label: Text(
              l10n.subscribeToKhawiPlusToRedeem,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => context.push(Routes.subscription),
          icon: const Icon(Icons.star, size: 16, color: AppTheme.accentGold),
          label: Text(
            '${l10n.subscribeToKhawiPlus} (${l10n.khawiPlusMonthlyPrice})',
            style: const TextStyle(color: AppTheme.accentGold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(WidgetRef ref, AppLocalizations l10n) {
    final transactionsAsync = ref.watch(xpTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) => Column(
        children: transactions
            .map(
              (tx) => _TransactionItem(
                title: tx.title,
                date: tx.createdAt.toString().split(' ')[0],
                amount: tx.amount,
                isNeutral: tx.type == 'debit',
              ),
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('${l10n.errorLoadingTransactions}: $err'),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isNeutral;

  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isNeutral,
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
            backgroundColor: isNeutral ? Colors.grey[100] : Colors.green[50],
            child: Icon(
              isNeutral ? Icons.shopping_basket : Icons.trending_up,
              color: isNeutral ? Colors.grey : Colors.green,
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
            amount,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: amount.startsWith('-')
                      ? Colors.red[700]
                      : AppTheme.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }
}
