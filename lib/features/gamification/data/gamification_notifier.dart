import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';

/// Writes gamification milestone notifications to the [notifications] table.
///
/// Anti-spam: each (user_id, event_key) pair is throttled to at most once
/// per [_throttleWindow]. This prevents notification flooding if the RPC
/// fires multiple times for the same milestone event.
class GamificationNotifier {
  GamificationNotifier(this._client);

  final SupabaseClient _client;

  static const _throttleWindow = Duration(hours: 4);

  // ── Public API ─────────────────────────────────────────────────────────

  /// Fires when a mission is fully completed.
  Future<void> onMissionCompleted({
    required String missionId,
    required String titleEn,
    required String titleAr,
    required int rewardXp,
  }) async {
    await _insert(
      eventKey: 'mission_completed:$missionId',
      type: 'gamification',
      titleEn: '🏆 Mission Complete!',
      titleAr: '🏆 مهمة مكتملة!',
      bodyEn: rewardXp > 0
          ? 'You completed "$titleEn" and earned $rewardXp XP.'
          : 'You completed "$titleEn".',
      bodyAr: rewardXp > 0
          ? 'أكملت "$titleAr" وحصلت على $rewardXp XP.'
          : 'أكملت "$titleAr".',
    );
  }

  /// Fires when a streak milestone is hit (e.g. 3, 7, 14, 30 days).
  Future<void> onStreakMilestone({
    required int streakCount,
  }) async {
    if (!_isMilestoneCount(streakCount)) return;

    await _insert(
      eventKey: 'streak_milestone:$streakCount',
      type: 'gamification',
      titleEn: '🔥 Streak Milestone!',
      titleAr: '🔥 إنجاز متتالية!',
      bodyEn: 'You hit a $streakCount-day commute streak. Keep it up!',
      bodyAr: 'حققت متتالية $streakCount يوم. استمر!',
    );
  }

  /// Fires when a streak enters grace (missed a day, recovery window open).
  Future<void> onStreakGrace({required int streakCount}) async {
    await _insert(
      eventKey:
          'streak_grace:${DateTime.now().toUtc().toIso8601String().substring(0, 10)}',
      type: 'gamification',
      titleEn: '⏳ Streak at Risk',
      titleAr: '⏳ متتالية في خطر',
      bodyEn:
          'You missed a day. Complete a trip in the next 24 h to recover your $streakCount-day streak!',
      bodyAr:
          'فاتك يوم. أكمل رحلة خلال 24 ساعة للحفاظ على متتالية $streakCount يوم!',
    );
  }

  /// Fires when a broken streak is recovered during the grace window.
  Future<void> onStreakRecovered({required int streakCount}) async {
    await _insert(
      eventKey:
          'streak_recovered:${DateTime.now().toUtc().toIso8601String().substring(0, 10)}',
      type: 'gamification',
      titleEn: '✅ Streak Recovered!',
      titleAr: '✅ تم استعادة المتتالية!',
      bodyEn: 'Great save! Your $streakCount-day streak continues.',
      bodyAr: 'أحسنت! متتالية $streakCount يوم تستمر.',
    );
  }

  // ── Internal ────────────────────────────────────────────────────────────

  Future<void> _insert({
    required String eventKey,
    required String type,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final cutoff = DateTime.now().toUtc().subtract(_throttleWindow);

      // Check throttle: skip if same event_key already inserted within window
      final existing = await _client
          .from(DbTable.notifications)
          .select('id')
          .eq(DbCol.userId, uid)
          .eq('event_key', eventKey)
          .gte(DbCol.createdAt, cutoff.toIso8601String())
          .limit(1)
          .maybeSingle();

      if (existing != null) return; // throttled

      await _client.from(DbTable.notifications).insert({
        DbCol.userId: uid,
        'event_key': eventKey,
        'type': type,
        'title_en': titleEn,
        'title_ar': titleAr,
        'body_en': bodyEn,
        'body_ar': bodyAr,
        DbCol.isRead: false,
        DbCol.createdAt: DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('GamificationNotifier._insert failed ($eventKey): $e');
      }
    }
  }

  static bool _isMilestoneCount(int count) {
    const milestones = {3, 7, 14, 21, 30, 50, 100};
    return milestones.contains(count);
  }
}
