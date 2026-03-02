import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/features/gamification/domain/streak_state.dart';
import 'package:khawi_flutter/features/gamification/domain/gamification_enums.dart';

/// Compact streak status card for role home or post-trip surfaces.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return streakAsync.when(
      data: (streak) => _StreakCardContent(streak: streak, isRtl: isRtl),
      loading: () => const _StreakCardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StreakCardContent extends StatelessWidget {
  const _StreakCardContent({
    required this.streak,
    required this.isRtl,
  });

  final StreakState streak;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysTxt = isRtl
        ? '${streak.currentCount} ${streak.currentCount == 1 ? 'يوم' : 'أيام'}'
        : '${streak.currentCount} ${streak.currentCount == 1 ? 'day' : 'days'}';

    return Semantics(
      label: isRtl
          ? 'سلسلة التنقل: $daysTxt. الحالة: ${streak.status.label(isRtl: isRtl)}'
          : 'Commute Streak: $daysTxt. Status: ${streak.status.label(isRtl: isRtl)}',
      excludeSemantics: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _statusIcon(streak.status),
                color: _statusColor(streak.status),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? 'سلسلة التنقل' : 'Commute Streak',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRtl
                          ? '${streak.currentCount} ${streak.currentCount == 1 ? 'يوم' : 'أيام'}'
                          : '${streak.currentCount} ${streak.currentCount == 1 ? 'day' : 'days'}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _statusColor(streak.status),
                      ),
                    ),
                    if (streak.isRecoverable)
                      Text(
                        isRtl ? 'يمكن الاستعادة!' : 'Recovery available!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    streak.status.label(isRtl: isRtl),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(streak.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRtl
                        ? 'الأطول: ${streak.longestCount}'
                        : 'Best: ${streak.longestCount}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(StreakStatus status) {
    switch (status) {
      case StreakStatus.active:
        return Icons.local_fire_department;
      case StreakStatus.grace:
        return Icons.hourglass_top;
      case StreakStatus.recovered:
        return Icons.replay;
      case StreakStatus.broken:
        return Icons.heart_broken;
    }
  }

  Color _statusColor(StreakStatus status) {
    switch (status) {
      case StreakStatus.active:
        return Colors.deepOrange;
      case StreakStatus.grace:
        return Colors.orange;
      case StreakStatus.recovered:
        return Colors.green;
      case StreakStatus.broken:
        return Colors.grey;
    }
  }
}

class _StreakCardSkeleton extends StatelessWidget {
  const _StreakCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 20,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
