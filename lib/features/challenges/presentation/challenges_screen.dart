import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';
import 'package:khawi_flutter/features/challenges/data/challenges_repository.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context)!;
    final challengesAsync = ref.watch(weeklyChallengesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(
          l10n.weeklyChallengesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        children: [
          challengesAsync.when(
            data: (challenges) => Column(
              children: challenges.map((challenge) {
                String title;
                String desc;
                String reward;
                IconData icon;
                Color color;

                switch (challenge.type) {
                  case ChallengeType.riyadhExplorer:
                    title = l10n.challengeRiyadhExplorer;
                    desc = l10n.challengeRiyadhExplorerDesc;
                    reward = l10n.challengeRiyadhExplorerXp;
                    icon = Icons.map;
                    color = AppTheme.driverAccent;
                    break;
                  case ChallengeType.ecoPioneer:
                    title = l10n.challengeEcoPioneer;
                    desc = l10n.challengeEcoPioneerDesc;
                    reward = l10n.challengeEcoPioneerXp;
                    icon = Icons.eco;
                    color = AppTheme.primaryGreen;
                    break;
                  case ChallengeType.safetyFirst:
                    title = l10n.challengeSafetyFirst;
                    desc = l10n.challengeSafetyFirstDesc;
                    reward = l10n.challengeSafetyFirstXp;
                    icon = Icons.verified_user;
                    color = AppTheme.accentGold;
                    break;
                }

                return _buildChallengeCard(
                  context,
                  title,
                  desc,
                  challenge.progress,
                  reward,
                  icon,
                  color,
                  isRtl,
                  l10n,
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.upcomingEvents,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          _buildEventTile(
            context,
            l10n.eventRamadanBonus,
            l10n.eventRamadanBonusDesc,
            l10n.eventRamadanBonusStart,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    String title,
    String desc,
    double progress,
    String reward,
    IconData icon,
    Color color,
    bool isRtl,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 24),
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
                          ?.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.challengePercentComplete((progress * 100).toInt()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                reward,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LevelProgressBar(
            value: progress,
            height: 10,
            glowColor: color.withValues(alpha: 0.3),
            gradient:
                LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(
    BuildContext context,
    String title,
    String desc,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
