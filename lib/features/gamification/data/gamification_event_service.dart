import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';

/// Gamification-specific event tracking service.
///
/// Follows the same fire-and-forget pattern as [EventLogService],
/// but writes gamification-specific event types for Tier-1 mechanics.
class GamificationEventService {
  GamificationEventService(this._sb);
  final SupabaseClient _sb;

  // ── Streak events ────────────────────────────────────────────────────────

  Future<void> logStreakContinued({
    required String tripId,
    required int newCount,
  }) =>
      _log(
        eventType: 'streak_continued',
        entityType: 'trip',
        entityId: tripId,
        payload: {'new_count': newCount},
      );

  Future<void> logStreakBroken({
    required int finalCount,
  }) =>
      _log(
        eventType: 'streak_broken',
        entityType: 'user',
        payload: {'final_count': finalCount},
      );

  Future<void> logStreakRecovered({
    required String tripId,
    required int restoredCount,
  }) =>
      _log(
        eventType: 'streak_recovered',
        entityType: 'trip',
        entityId: tripId,
        payload: {'restored_count': restoredCount},
      );

  // ── Mission events ───────────────────────────────────────────────────────

  Future<void> logMissionProgress({
    required String missionId,
    required int currentCount,
    required int targetCount,
  }) =>
      _log(
        eventType: 'mission_progress',
        entityType: 'mission',
        entityId: missionId,
        payload: {
          'current_count': currentCount,
          'target_count': targetCount,
        },
      );

  Future<void> logMissionCompleted({
    required String missionId,
    required int rewardXp,
  }) =>
      _log(
        eventType: 'mission_completed',
        entityType: 'mission',
        entityId: missionId,
        payload: {'reward_xp': rewardXp},
      );

  // ── Wallet events ────────────────────────────────────────────────────────

  Future<void> logWalletViewed() =>
      _log(eventType: 'wallet_viewed', entityType: 'wallet');

  Future<void> logRewardRedeemed({
    required String rewardId,
    required int cost,
  }) =>
      _log(
        eventType: 'reward_redeemed',
        entityType: 'reward',
        entityId: rewardId,
        payload: {'cost': cost},
      );

  // ── NBA events ───────────────────────────────────────────────────────────

  Future<void> logNbaShown({
    required String actionType,
  }) =>
      _log(
        eventType: 'nba_shown',
        entityType: 'nba',
        payload: {'action_type': actionType},
      );

  Future<void> logNbaClicked({
    required String actionType,
  }) =>
      _log(
        eventType: 'nba_clicked',
        entityType: 'nba',
        payload: {'action_type': actionType},
      );

  // ── Progress snapshot events ─────────────────────────────────────────────

  Future<void> logProgressViewed({
    required String surface,
  }) =>
      _log(
        eventType: 'progress_viewed',
        entityType: 'progress',
        payload: {'surface': surface},
      );

  // ── Experiment events (Tier-2) ─────────────────────────────────────────

  Future<void> logCohortAssigned({
    required String experimentId,
    required String cohort,
    required String variant,
  }) =>
      _log(
        eventType: 'cohort_assigned',
        entityType: 'experiment',
        entityId: experimentId,
        payload: {'cohort': cohort, 'variant': variant},
      );

  Future<void> logFeatureExposed({
    required String experimentId,
    required String cohort,
    required String featureFlag,
  }) =>
      _log(
        eventType: 'feature_exposed',
        entityType: 'experiment',
        entityId: experimentId,
        payload: {'cohort': cohort, 'feature_flag': featureFlag},
      );

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<void> _log({
    required String eventType,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? payload,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': eventType,
        'entity_type': entityType,
        if (entityId != null) 'entity_id': entityId,
        if (payload != null) 'payload': payload,
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('GamificationEventService.$eventType failed: $e');
      }
    }
  }
}
