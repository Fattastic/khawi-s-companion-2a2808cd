import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/features/gamification/presentation/wallet_summary_tile.dart';
import 'package:khawi_flutter/features/rewards/data/mock_rewards_provider.dart';
import 'package:khawi_flutter/features/rewards/presentation/widgets/reward_card.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(
          isRtl ? "مركز المكافآت" : "Rewards Central",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KhawiMotion.slideUpFadeIn(_buildXpOverview(ref, isRtl), index: 0),
            const SizedBox(height: AppTheme.spacing24),
            KhawiMotion.slideUpFadeIn(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(isRtl ? 'محفظة القيمة' : 'VALUE WALLET'),
                  const SizedBox(height: AppTheme.spacing16),
                  const WalletSummaryTile(),
                ],
              ),
              index: 1,
            ),
            const SizedBox(height: AppTheme.spacing32),
            KhawiMotion.slideUpFadeIn(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    isRtl ? "التحديات النشطة" : "ACTIVE CHALLENGES",
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildChallengesList(ref, isRtl),
                ],
              ),
              index: 2,
            ),
            const SizedBox(height: AppTheme.spacing32),
            KhawiMotion.slideUpFadeIn(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    isRtl ? "مستويات المكافآت" : "TIERED REWARDS",
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildRewardTier(
                    isRtl ? "البرونزي" : "Bronze",
                    isRtl ? "المستوى 1-5" : "Level 1-5",
                    true,
                    isRtl,
                  ),
                  _buildRewardTier(
                    isRtl ? "الفضي" : "Silver",
                    isRtl ? "المستوى 6-15" : "Level 6-15",
                    false,
                    isRtl,
                  ),
                  _buildRewardTier(
                    isRtl ? "الذهبي" : "Gold",
                    isRtl ? "المستوى +16" : "Level 16+",
                    false,
                    isRtl,
                  ),
                ],
              ),
              index: 3,
            ),
            const SizedBox(height: AppTheme.spacing32),
            KhawiMotion.slideUpFadeIn(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    isRtl ? "مكافآت حصرية" : "EXCLUSIVE REWARDS",
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildRewardsGrid(ref, isRtl),
                ],
              ),
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsGrid(WidgetRef ref, bool isRtl) {
    final rewards = ref.watch(mockRewardsProvider);
    final userProfile = ref.watch(myProfileProvider).valueOrNull;
    final isPremium = ref.watch(premiumProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final item = rewards[index];
        return RewardCard(
          item: item,
          isRtl: isRtl,
          userXp: userProfile?.totalXp ?? 0,
          userTier: TrustTier.bronze, // Temporary static tier
          isSubscribed: isPremium,
          onTap: () => context.push(Routes.sharedRedeem),
        );
      },
    );
  }

  Widget _buildXpOverview(WidgetRef ref, bool isRtl) {
    final profileAsync = ref.watch(myProfileProvider);
    return profileAsync.when(
      data: (profile) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppTheme.accentGold,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl
                          ? "${profile.totalXp} نقاط XP"
                          : "${profile.totalXp} Total XP",
                      style: Theme.of(ref.context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isRtl
                          ? "عضو المستوى ${profile.totalXp ~/ 1000 + 1}"
                          : "Level ${profile.totalXp ~/ 1000 + 1} Member",
                      style: Theme.of(ref.context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            LevelProgressBar(
              value: (profile.totalXp % 1000) / 1000,
              level: profile.totalXp ~/ 1000 + 1,
              gradient: AppTheme.goldGradient,
            ),
            const SizedBox(height: 12),
            Text(
              isRtl
                  ? "${1000 - (profile.totalXp % 1000)} XP للمستوى التالي"
                  : "${1000 - (profile.totalXp % 1000)} XP until next level",
              style: Theme.of(ref.context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text(
        isRtl ? "خطأ في تحميل حالة المكافآت" : "Error loading rewards status",
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildChallengeCard(
    String title,
    String desc,
    double progress,
    String reward,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                reward,
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LevelProgressBar(
            value: progress,
            height: 8,
            milestones: const [0.5, 1.0],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(WidgetRef ref, bool isRtl) {
    final challengesAsync = ref.watch(activeChallengesProvider);
    return challengesAsync.when(
      data: (challenges) => Column(
        children: challenges
            .map(
              (c) => _buildChallengeCard(
                c.title,
                c.description,
                c.progress,
                c.reward,
              ),
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text(
        isRtl
            ? "خطأ في تحميل التحديات: $err"
            : "Error loading challenges: $err",
      ),
    );
  }

  Widget _buildRewardTier(
    String name,
    String level,
    bool isUnlocked,
    bool isRtl,
  ) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: isUnlocked ? null : Border.all(color: AppTheme.borderColor),
          boxShadow: isUnlocked ? AppTheme.shadowSmall : null,
        ),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? AppTheme.success : AppTheme.textTertiary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
