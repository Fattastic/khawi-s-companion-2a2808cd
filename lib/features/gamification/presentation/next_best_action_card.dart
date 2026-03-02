import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/data/core/supabase_provider.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/features/gamification/domain/gamification_enums.dart';
import 'package:khawi_flutter/features/gamification/domain/next_best_action.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Home-screen card that renders the current Next Best Action recommendation.
///
/// On tap, logs a click event to [DbTable.nbaClickEvents] and optionally
/// navigates to the action's deep link.
class NextBestActionCard extends ConsumerWidget {
  const NextBestActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nbaAsync = ref.watch(nextActionProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return nbaAsync.when(
      data: (nba) {
        if (nba == null || nba.isExpired) return const SizedBox.shrink();
        return _NbaCard(nba: nba, isRtl: isRtl);
      },
      loading: () => const _NbaSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Internal Card ─────────────────────────────────────────────────────────────

class _NbaCard extends ConsumerWidget {
  const _NbaCard({required this.nba, required this.isRtl});

  final NextBestAction nba;
  final bool isRtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _actionColor(nba.actionType);
    final icon = _actionIcon(nba.actionType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onTap(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nba.localizedTitle(isRtl: isRtl),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nba.localizedSubtitle(isRtl: isRtl),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // XP badge + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (nba.potentialXp > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${nba.potentialXp} XP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Icon(
                    isRtl
                        ? Icons.arrow_back_ios_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    // 1. Log click event (fire-and-forget; failures are non-blocking)
    final uid = ref.read(userIdProvider);
    if (uid != null) {
      final SupabaseClient sb = ref.read(supabaseProvider);
      unawaited(
        sb
            .from(DbTable.nbaClickEvents)
            .insert({
              'user_id': uid,
              'action_type': nba.actionType.key,
              'reason': nba.reason,
              'potential_xp': nba.potentialXp,
              'deep_link': nba.deepLink,
            })
            .then<void>((_) {})
            .catchError((_) {}),
      );
    }

    // 2. Navigate if deep link provided
    if (nba.deepLink != null && context.mounted) {
      unawaited(context.push(nba.deepLink!));
    }
  }

  static Color _actionColor(ActionType type) {
    switch (type) {
      case ActionType.recoverStreak:
        return Colors.orange;
      case ActionType.completeMission:
        return Colors.blue;
      case ActionType.startStreak:
        return Colors.green;
      case ActionType.inviteFriend:
        return Colors.purple;
      case ActionType.ratePastRide:
        return Colors.amber;
      case ActionType.completeProfile:
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  static IconData _actionIcon(ActionType type) {
    switch (type) {
      case ActionType.recoverStreak:
        return Icons.local_fire_department_rounded;
      case ActionType.completeMission:
        return Icons.flag_rounded;
      case ActionType.startStreak:
        return Icons.rocket_launch_rounded;
      case ActionType.inviteFriend:
        return Icons.person_add_rounded;
      case ActionType.ratePastRide:
        return Icons.star_rounded;
      case ActionType.completeProfile:
        return Icons.account_circle_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _NbaSkeleton extends StatelessWidget {
  const _NbaSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 13,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 200,
                  height: 11,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
