/// GAMI-207: Unit tests for streak state transitions and mission progress
/// edge cases. These tests exercise the Dart domain model logic directly —
/// they do not require a live Supabase connection.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/gamification/domain/gamification_enums.dart';
import 'package:khawi_flutter/features/gamification/domain/mission.dart';
import 'package:khawi_flutter/features/gamification/domain/streak_state.dart';

void main() {
  group('StreakState domain model', () {
    test('empty() produces broken state with zero counts', () {
      final state = StreakState.empty('user-1');
      expect(state.status, StreakStatus.broken);
      expect(state.currentCount, 0);
      expect(state.longestCount, 0);
      expect(state.graceExpiresAt, isNull);
      expect(state.isRecoverable, isFalse);
    });

    test('isRecoverable is true when status=grace and window is in future', () {
      final state = StreakState(
        userId: 'u',
        currentCount: 5,
        longestCount: 10,
        status: StreakStatus.grace,
        graceExpiresAt: DateTime.now().add(const Duration(hours: 12)),
        lastQualifyingTripAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
      expect(state.isRecoverable, isTrue);
    });

    test('isRecoverable is false when grace window has expired', () {
      final state = StreakState(
        userId: 'u',
        currentCount: 3,
        longestCount: 3,
        status: StreakStatus.grace,
        graceExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        lastQualifyingTripAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );
      expect(state.isRecoverable, isFalse);
    });

    test('isRecoverable is false when status=active', () {
      final state = StreakState(
        userId: 'u',
        currentCount: 7,
        longestCount: 14,
        status: StreakStatus.active,
        graceExpiresAt: null,
        lastQualifyingTripAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(state.isRecoverable, isFalse);
    });

    test('fromJson parses all fields correctly', () {
      final now = DateTime.utc(2026, 2, 18, 12);
      final grace = DateTime.utc(2026, 2, 19, 12);
      final json = {
        'user_id': 'abc',
        'current_count': 7,
        'longest_count': 14,
        'status': 'grace',
        'grace_expires_at': grace.toIso8601String(),
        'last_qualifying_trip_at': null,
        'last_trip_at': null,
        'updated_at': now.toIso8601String(),
      };
      final state = StreakState.fromJson(json);
      expect(state.userId, 'abc');
      expect(state.currentCount, 7);
      expect(state.longestCount, 14);
      expect(state.status, StreakStatus.grace);
      expect(state.graceExpiresAt, isNotNull);
    });

    test('fromJson treats missing/null grace_expires_at as null', () {
      final json = {
        'user_id': 'x',
        'current_count': 0,
        'longest_count': 0,
        'status': 'broken',
        'updated_at': DateTime.now().toIso8601String(),
      };
      final state = StreakState.fromJson(json);
      expect(state.graceExpiresAt, isNull);
    });

    test('StreakStatus.fromString maps all valid values', () {
      expect(StreakStatus.fromString('active'), StreakStatus.active);
      expect(StreakStatus.fromString('grace'), StreakStatus.grace);
      expect(StreakStatus.fromString('broken'), StreakStatus.broken);
      expect(StreakStatus.fromString('recovered'), StreakStatus.recovered);
    });

    test('StreakStatus.fromString falls back to broken for unknown value', () {
      expect(StreakStatus.fromString('unknown_xyz'), StreakStatus.broken);
    });
  });

  group('Mission domain model', () {
    Mission makeMission({
      int currentCount = 0,
      int targetCount = 3,
      MissionStatus status = MissionStatus.active,
      DateTime? weekEnd,
    }) {
      final end = weekEnd ?? DateTime.now().add(const Duration(days: 3));
      return Mission(
        id: 'm-1',
        userId: 'u-1',
        title: 'Complete 3 trips',
        titleAr: 'أكمل 3 رحلات',
        description: 'Finish 3 trips this week',
        descriptionAr: 'أكمل 3 رحلات هذا الأسبوع',
        category: MissionCategory.commute,
        status: status,
        targetCount: targetCount,
        currentCount: currentCount,
        rewardXp: 100,
        weekStart: DateTime.now().subtract(const Duration(days: 2)),
        weekEnd: end,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
    }

    test('progress is 0.0 for untouched mission', () {
      expect(makeMission(currentCount: 0).progress, 0.0);
    });

    test('progress is 1.0 when currentCount equals targetCount', () {
      expect(makeMission(currentCount: 3, targetCount: 3).progress, 1.0);
    });

    test('progress is clamped to 1.0 when currentCount exceeds targetCount',
        () {
      expect(makeMission(currentCount: 5, targetCount: 3).progress, 1.0);
    });

    test('isComplete is true when currentCount >= targetCount', () {
      expect(makeMission(currentCount: 3, targetCount: 3).isComplete, isTrue);
      expect(makeMission(currentCount: 4, targetCount: 3).isComplete, isTrue);
    });

    test('isComplete is false when currentCount < targetCount', () {
      expect(makeMission(currentCount: 2, targetCount: 3).isComplete, isFalse);
    });

    test('isExpired is true for past weekEnd', () {
      final m = makeMission(
        weekEnd: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(m.isExpired, isTrue);
    });

    test('isExpired is false for future weekEnd', () {
      expect(makeMission().isExpired, isFalse);
    });

    test('localizedTitle returns titleAr when isRtl=true', () {
      expect(
        makeMission().localizedTitle(isRtl: true),
        'أكمل 3 رحلات',
      );
    });

    test('localizedTitle returns title when isRtl=false', () {
      expect(
        makeMission().localizedTitle(isRtl: false),
        'Complete 3 trips',
      );
    });

    test('progress is 0.0 when targetCount is 0 (division guard)', () {
      expect(makeMission(targetCount: 0).progress, 0.0);
    });

    test('fromJson parses status and category correctly', () {
      final json = {
        'id': 'm-1',
        'user_id': 'u-1',
        'title': 'T',
        'title_ar': 'ت',
        'description': 'D',
        'description_ar': 'د',
        'category': 'commute',
        'status': 'active',
        'target_count': 5,
        'current_count': 2,
        'reward_xp': 50,
        'week_start': '2026-02-18',
        'week_end': '2026-02-25T00:00:00.000Z',
        'created_at': '2026-02-18T00:00:00.000Z',
      };
      final m = Mission.fromJson(json);
      expect(m.category, MissionCategory.commute);
      expect(m.status, MissionStatus.active);
      expect(m.targetCount, 5);
      expect(m.currentCount, 2);
    });
  });

  group('MissionCategory enum', () {
    test('fromString maps known values', () {
      expect(MissionCategory.fromString('commute'), MissionCategory.commute);
      expect(MissionCategory.fromString('social'), MissionCategory.social);
      expect(MissionCategory.fromString('safety'), MissionCategory.safety);
      expect(MissionCategory.fromString('general'), MissionCategory.general);
    });

    test('fromString falls back to general for unknown value', () {
      expect(
        MissionCategory.fromString('unknown_anything'),
        MissionCategory.general,
      );
    });
  });

  group('MissionStatus enum', () {
    test('fromString maps known values', () {
      expect(MissionStatus.fromString('active'), MissionStatus.active);
      expect(MissionStatus.fromString('completed'), MissionStatus.completed);
      expect(MissionStatus.fromString('expired'), MissionStatus.expired);
      expect(MissionStatus.fromString('cancelled'), MissionStatus.cancelled);
    });

    test('fromString falls back to active for unknown input', () {
      expect(
        MissionStatus.fromString('xyz'),
        MissionStatus.active,
      );
    });
  });
}
