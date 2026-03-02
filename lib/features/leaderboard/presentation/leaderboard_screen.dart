import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:khawi_flutter/state/providers.dart';

final _leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>(
  (ref) => ref.watch(leaderboardRepoProvider).fetchTop(limit: 30),
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final asyncData = ref.watch(_leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'لوحة المتصدرين' : 'Leaderboard'),
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  isRtl ? 'تعذر تحميل المتصدرين' : 'Could not load leaderboard',
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(_leaderboardProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                isRtl
                    ? 'لا توجد بيانات متصدرين حالياً'
                    : 'No leaderboard data yet',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return KhawiMotion.slideUpFadeIn(
                _LeaderboardTile(entry: entry, isRtl: isRtl),
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, required this.isRtl});

  final LeaderboardEntry entry;
  final bool isRtl;

  String _rankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trust = (entry.trustBadge ?? '').trim();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.backgroundNeutral,
          child: Text(
            _rankBadge(entry.rank),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          entry.displayName,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: trust.isEmpty
            ? null
            : Text(
                isRtl ? 'الثقة: $trust' : 'Trust: $trust',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
        trailing: Text(
          '${entry.totalXp} XP',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryGreenDark,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
