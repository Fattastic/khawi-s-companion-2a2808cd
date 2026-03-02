import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/gamification/presentation/mission_card_list.dart';
import 'package:khawi_flutter/features/gamification/presentation/streak_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/wallet_summary_tile.dart';

class KidsRewardsScreen extends StatefulWidget {
  const KidsRewardsScreen({super.key});

  @override
  State<KidsRewardsScreen> createState() => _KidsRewardsScreenState();
}

class _KidsRewardsScreenState extends State<KidsRewardsScreen> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    const rewards = [
      (title: 'Avatar Pack', subtitle: 'Unlock at 500 XP', unlocked: true),
      (
        title: 'Route Hero Badge',
        subtitle: 'Unlock at 1000 XP',
        unlocked: false
      ),
      (
        title: 'Gold Streak Trail',
        subtitle: 'Unlock at 1500 XP',
        unlocked: false
      ),
    ];

    final visibleRewards = switch (_selectedFilter) {
      1 => rewards.where((r) => r.unlocked).toList(),
      2 => rewards.where((r) => !r.unlocked).toList(),
      _ => rewards,
    };

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'مكافآت خواي جونيور' : 'Khawi Junior Rewards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        children: [
          KhawiMotion.slideUpFadeIn(
            _RewardsHeroCard(isRtl: isRtl),
            index: 0,
          ),
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            const WalletSummaryTile(),
            index: 1,
          ),
          const SizedBox(height: AppTheme.spacing12),
          KhawiMotion.slideUpFadeIn(
            const StreakCard(),
            index: 2,
          ),
          const SizedBox(height: AppTheme.spacing12),
          KhawiMotion.slideUpFadeIn(
            const MissionCardList(),
            index: 3,
          ),
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            _RewardsFilterBar(
              selected: _selectedFilter,
              onChange: (idx) => setState(() => _selectedFilter = idx),
            ),
            index: 4,
          ),
          const SizedBox(height: AppTheme.spacing12),
          KhawiMotion.slideUpFadeIn(
            _RewardCatalogSection(
              isRtl: isRtl,
              rewards: visibleRewards,
            ),
            index: 5,
          ),
        ],
      ),
    );
  }
}

class _RewardsFilterBar extends StatelessWidget {
  const _RewardsFilterBar({
    required this.selected,
    required this.onChange,
  });

  final int selected;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['All', 'Unlocked', 'Upcoming'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.primaryGreen.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: active
                            ? AppTheme.primaryGreenDark
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RewardsHeroCard extends StatelessWidget {
  const _RewardsHeroCard({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.premiumGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowColored(AppTheme.accentGoldDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'العب، تعلّم، واربح' : 'Play, Learn, Earn',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isRtl
                ? 'كل رحلة آمنة ومهمة مكتملة تزيد مكافآتك.'
                : 'Every safe run and completed mission grows your rewards.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _RewardCatalogSection extends StatelessWidget {
  const _RewardCatalogSection({
    required this.isRtl,
    required this.rewards,
  });

  final bool isRtl;
  final List<({String title, String subtitle, bool unlocked})> rewards;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'مكافآت قادمة' : 'Upcoming Rewards',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            if (rewards.isEmpty)
              Text(
                isRtl
                    ? 'No rewards in this category yet.'
                    : 'No rewards in this category yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
            else
              ...rewards.map(
                (reward) => _RewardRow(
                  title: reward.title,
                  subtitle: reward.subtitle,
                  icon: reward.unlocked
                      ? Icons.emoji_emotions_outlined
                      : Icons.lock_outline,
                  unlocked: reward.unlocked,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor),
        color: unlocked
            ? AppTheme.primaryGreen.withValues(alpha: 0.06)
            : Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: unlocked
                ? AppTheme.primaryGreen.withValues(alpha: 0.14)
                : AppTheme.borderLight,
            child: Icon(
              unlocked ? Icons.verified : icon,
              color:
                  unlocked ? AppTheme.primaryGreenDark : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
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
