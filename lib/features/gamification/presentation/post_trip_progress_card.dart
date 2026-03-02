import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/features/gamification/domain/progress_snapshot.dart';

/// Read-only progress feedback card for post-trip summary screen.
///
/// Shows streak continuation, mission progress, and wallet delta in a
/// single compact card added after trip completion. Must not add latency
/// to the booking or post-trip flow.
class PostTripProgressCard extends ConsumerWidget {
  const PostTripProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(progressSnapshotProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return snapshotAsync.when(
      data: (snapshot) => _PostTripContent(snapshot: snapshot, isRtl: isRtl),
      loading: () => const _PostTripSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PostTripContent extends StatefulWidget {
  const _PostTripContent({
    required this.snapshot,
    required this.isRtl,
  });

  final ProgressSnapshot snapshot;
  final bool isRtl;

  @override
  State<_PostTripContent> createState() => _PostTripContentState();
}

class _PostTripContentState extends State<_PostTripContent> {
  Timer? _bannerTimer;
  String? _milestoneMessage;
  int? _lastMissionCount;
  int? _lastStreakCount;
  int? _lastBalance;

  @override
  void initState() {
    super.initState();
    _lastMissionCount = widget.snapshot.completedMissionCount;
    _lastStreakCount = widget.snapshot.streak.currentCount;
    _lastBalance = widget.snapshot.walletSummary.availableBalance;
  }

  @override
  void didUpdateWidget(covariant _PostTripContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final snapshot = widget.snapshot;
    final missionCount = snapshot.completedMissionCount;
    final streakCount = snapshot.streak.currentCount;
    final balance = snapshot.walletSummary.availableBalance;

    if (_lastMissionCount != null && missionCount > _lastMissionCount!) {
      _showMilestone(
        widget.isRtl ? 'تم إكمال مهمة جديدة' : 'New mission completed',
      );
    } else if (_lastStreakCount != null && streakCount > _lastStreakCount!) {
      _showMilestone(
        widget.isRtl ? 'تم تحديث سلسلة التنقل' : 'Streak advanced',
      );
    } else if (_lastBalance != null && balance > _lastBalance!) {
      _showMilestone(
        widget.isRtl ? 'تمت إضافة رصيد جديد' : 'Wallet balance increased',
      );
    }

    _lastMissionCount = missionCount;
    _lastStreakCount = streakCount;
    _lastBalance = balance;
  }

  void _showMilestone(String message) {
    if (!mounted) return;
    _bannerTimer?.cancel();
    setState(() => _milestoneMessage = message);
    _bannerTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _milestoneMessage = null);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = widget.snapshot;
    final isRtl = widget.isRtl;
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: duration,
              alignment: Alignment.centerLeft,
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _milestoneMessage == null
                    ? const SizedBox.shrink(
                        key: ValueKey('no_milestone_banner'),)
                    : Container(
                        key: ValueKey(_milestoneMessage),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _milestoneMessage!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Text(
              isRtl ? 'تقدمك' : 'Your Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            _ProgressRow(
              icon: Icons.local_fire_department,
              iconColor: Colors.deepOrange,
              label: isRtl ? 'سلسلة التنقل' : 'Streak',
              value: isRtl
                  ? '${snapshot.streak.currentCount} أيام'
                  : '${snapshot.streak.currentCount} days',
            ),
            const SizedBox(height: 8),
            _ProgressRow(
              icon: Icons.flag,
              iconColor: Colors.blue,
              label: isRtl ? 'المهام' : 'Missions',
              value: isRtl
                  ? '${snapshot.completedMissionCount}/${snapshot.activeMissions.length} مكتملة'
                  : '${snapshot.completedMissionCount}/${snapshot.activeMissions.length} done',
            ),
            const SizedBox(height: 8),
            _ProgressRow(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.green,
              label: isRtl ? 'الرصيد' : 'Balance',
              value: '${snapshot.walletSummary.availableBalance}',
            ),
            if (snapshot.nextAction != null) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      snapshot.nextAction!.localizedTitle(isRtl: isRtl),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                  if (snapshot.nextAction!.potentialXp > 0)
                    Text(
                      '+${snapshot.nextAction!.potentialXp} XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            value,
            key: ValueKey(value),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

class _PostTripSkeleton extends StatelessWidget {
  const _PostTripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 16, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.grey.shade200,
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 14,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
