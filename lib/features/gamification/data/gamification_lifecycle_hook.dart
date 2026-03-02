import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_event_service.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_notifier.dart';

/// Bridges ride-lifecycle transitions to gamification systems.
///
/// Call the appropriate method at each trip lifecycle point. All operations
/// are fire-and-forget — they never block the caller and silently catch
/// errors in non-release builds.
class GamificationLifecycleHook {
  GamificationLifecycleHook(this._sb, this._events, this._notifier);

  final SupabaseClient _sb;
  final GamificationEventService _events;
  final GamificationNotifier _notifier;

  // ── Trip completed ─────────────────────────────────────────────────────

  /// Called after [completeTripV2] succeeds.
  /// Evaluates streak continuation and mission progress, then fires events.
  ///
  /// GAMI-306: Before processing, calls the anti-fraud guard RPC.
  /// If the guard blocks the event, processing is skipped silently.
  Future<void> onTripCompleted(String tripId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    try {
      // 0. Anti-fraud guard (GAMI-306) — checks rate limit + records event
      final guardResult = await _sb.rpc<bool>(
        DbRpc.checkGamificationFraudGuard,
        params: {
          'p_user_id': uid,
          'p_event_key': 'trip_completed',
        },
      );
      if (guardResult == false) {
        if (!kReleaseMode) {
          debugPrint(
            'GamificationLifecycleHook: trip_completed blocked by fraud guard for $uid',
          );
        }
        return;
      }

      // 1. Evaluate streak
      final streakResult = await _sb.rpc<Map<String, dynamic>>(
        DbRpc.evaluateStreakOnTrip,
        params: {'p_user_id': uid, 'p_trip_id': tripId},
      );

      final changed = streakResult['changed'] == true;
      final status = streakResult['status'] as String?;
      final count = (streakResult['current_count'] as num?)?.toInt() ?? 0;
      final transition = streakResult['transition'] as String?;

      if (changed) {
        if (status == 'recovered') {
          unawaited(
            _events.logStreakRecovered(
              tripId: tripId,
              restoredCount: count,
            ),
          );
          unawaited(_notifier.onStreakRecovered(streakCount: count));
        } else {
          unawaited(
            _events.logStreakContinued(tripId: tripId, newCount: count),
          );
          // Fire milestone notification on notable streak counts
          unawaited(_notifier.onStreakMilestone(streakCount: count));
        }

        // Notify user if streak entered grace (transition = 'grace_recovered'
        // means they just recovered; for entering grace use expire_stale_streaks)
        if (transition == 'grace_recovered') {
          unawaited(_notifier.onStreakRecovered(streakCount: count));
        }
      }

      // 2. Evaluate mission progress (commute category)
      final missionResult = await _sb.rpc<Map<String, dynamic>>(
        DbRpc.evaluateMissionProgress,
        params: {'p_user_id': uid, 'p_category': 'commute'},
      );

      final updated = missionResult['missions_updated'] as List? ?? [];
      for (final m in updated) {
        final map = m as Map<String, dynamic>;
        final missionId = map['mission_id'] as String? ?? '';
        final newCount = (map['new_count'] as num?)?.toInt() ?? 0;
        final target = (map['target'] as num?)?.toInt() ?? 1;
        final completed = map['completed'] == true;

        if (completed) {
          // Compute reward XP (best-effort — if column not in result, use 0)
          final rewardXp = (map['reward_xp'] as num?)?.toInt() ?? 0;
          unawaited(
            _events.logMissionCompleted(
                missionId: missionId, rewardXp: rewardXp,),
          );
          // Fire in-app notification
          unawaited(
            _notifier.onMissionCompleted(
              missionId: missionId,
              titleEn: map['title_en'] as String? ?? '',
              titleAr: map['title_ar'] as String? ?? '',
              rewardXp: rewardXp,
            ),
          );
        } else {
          unawaited(
            _events.logMissionProgress(
              missionId: missionId,
              currentCount: newCount,
              targetCount: target,
            ),
          );
        }
      }

      // 3. Recompute wallet
      unawaited(
        _sb.rpc<dynamic>(
          DbRpc.computeWalletSummary,
          params: {'p_user_id': uid},
        ),
      );

      // 4. Log progress viewed (post-trip surface)
      unawaited(_events.logProgressViewed(surface: 'post_trip'));
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('GamificationLifecycleHook.onTripCompleted failed: $e');
      }
    }
  }

  // ── Trip shared ────────────────────────────────────────────────────────

  /// Called after a trip share event (auto or manual).
  /// Evaluates social mission progress.
  Future<void> onTripShared() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    try {
      await _sb.rpc<dynamic>(
        DbRpc.evaluateMissionProgress,
        params: {'p_user_id': uid, 'p_category': 'social'},
      );
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('GamificationLifecycleHook.onTripShared failed: $e');
      }
    }
  }

  // ── Rating submitted ──────────────────────────────────────────────────

  /// Called after a rating is submitted (driver or passenger side).
  /// Evaluates safety mission progress.
  Future<void> onRatingSubmitted() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    try {
      await _sb.rpc<dynamic>(
        DbRpc.evaluateMissionProgress,
        params: {'p_user_id': uid, 'p_category': 'safety'},
      );
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('GamificationLifecycleHook.onRatingSubmitted failed: $e');
      }
    }
  }

  // ── Weekly mission assignment ──────────────────────────────────────────

  /// Called on app launch or session start to ensure the user has weekly
  /// missions assigned. Idempotent — safe to call multiple times.
  Future<void> ensureWeeklyMissions() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    try {
      await _sb.rpc<dynamic>(
        DbRpc.assignWeeklyMissions,
        params: {'p_user_id': uid},
      );
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint(
          'GamificationLifecycleHook.ensureWeeklyMissions failed: $e',
        );
      }
    }
  }
}
