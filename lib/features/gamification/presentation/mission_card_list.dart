import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';
import 'package:khawi_flutter/core/widgets/app_skeleton_loader.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';
import 'package:khawi_flutter/features/challenges/data/challenges_repository.dart';

/// Horizontal challenge card list for role home (Gamification Dashboard).
class MissionCardList extends ConsumerWidget {
  const MissionCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(weeklyChallengesProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppEmptyState(
              icon: Icons.star_border,
              title: isRtl ? 'لا توجد مهام' : 'No active missions',
              subtitle: isRtl ? 'تحقق لاحقاً' : 'Check back later',
              isRtl: isRtl,
            ),
          );
        }
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                isRtl ? 'المهام الأسبوعية' : 'Weekly Missions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _ChallengeCard(
                  challenge: challenges[i],
                  isRtl: isRtl,
                  l10n: l10n,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const AppSkeletonLoader(
            width: 220,
            height: 140,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.isRtl,
    required this.l10n,
  });

  final Challenge challenge;
  final bool isRtl;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Provide fallbacks in case l10n is null (rare but safe)
    final title = _getLocalizedTitle();
    final desc = _getLocalizedDescription();
    final reward = _getLocalizedReward();
    final iconData = _getIcon();

    return SizedBox(
      width: 240, // Slightly wider for better text fit
      child: AppCard(
        mainAxisSize: MainAxisSize.max,
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        hasShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  iconData,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const SizedBox(height: 8),
            LevelProgressBar(
              value: challenge.progress,
              height: 10,
              glowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reward,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(challenge.progress * 100).toInt()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle() {
    if (l10n == null) return challenge.type.name;
    switch (challenge.type) {
      case ChallengeType.riyadhExplorer:
        return l10n!.challengeRiyadhExplorer;
      case ChallengeType.ecoPioneer:
        return l10n!.challengeEcoPioneer;
      case ChallengeType.safetyFirst:
        return l10n!.challengeSafetyFirst;
    }
  }

  String _getLocalizedDescription() {
    if (l10n == null) return '';
    switch (challenge.type) {
      case ChallengeType.riyadhExplorer:
        return l10n!.challengeRiyadhExplorerDesc;
      case ChallengeType.ecoPioneer:
        return l10n!.challengeEcoPioneerDesc;
      case ChallengeType.safetyFirst:
        return l10n!.challengeSafetyFirstDesc;
    }
  }

  String _getLocalizedReward() {
    switch (challenge.type) {
      case ChallengeType.riyadhExplorer:
        return isRtl ? '+٥٠٠ نقطة' : '+500 XP';
      case ChallengeType.ecoPioneer:
        return isRtl ? '+٣٠٠ نقطة' : '+300 XP';
      case ChallengeType.safetyFirst:
        return isRtl ? '+٢٥٠ نقطة' : '+250 XP';
    }
  }

  IconData _getIcon() {
    switch (challenge.type) {
      case ChallengeType.riyadhExplorer:
        return Icons.map_outlined;
      case ChallengeType.ecoPioneer:
        return Icons.eco_outlined;
      case ChallengeType.safetyFirst:
        return Icons.health_and_safety_outlined;
    }
  }
}
