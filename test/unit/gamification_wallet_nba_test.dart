/// GAMI-307: Sprint 3 unit tests — Value Wallet, NBA, ActionType, and fraud-guard invariants.
/// These tests exercise Dart domain logic only. No live Supabase connection required.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/gamification/domain/gamification_enums.dart';
import 'package:khawi_flutter/features/gamification/domain/next_best_action.dart';
import 'package:khawi_flutter/features/gamification/domain/wallet.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // WalletSummary domain model
  // ───────────────────────────────────────────────────────────────────────────

  group('WalletSummary', () {
    test('empty() produces zero totals and non-null updatedAt', () {
      final ws = WalletSummary.empty('u1');
      expect(ws.earnedTotal, 0);
      expect(ws.unlockedTotal, 0);
      expect(ws.pendingTotal, 0);
      expect(ws.redeemedTotal, 0);
      expect(ws.availableBalance, 0);
      expect(ws.userId, 'u1');
    });

    test('availableBalance = unlockedTotal - redeemedTotal', () {
      final ws = WalletSummary(
        userId: 'u',
        earnedTotal: 1000,
        unlockedTotal: 700,
        pendingTotal: 300,
        redeemedTotal: 200,
        updatedAt: DateTime.now(),
      );
      expect(ws.availableBalance, 500);
    });

    test('fromJson reads total_* DB columns correctly', () {
      final json = {
        'user_id': 'abc',
        'total_earned': 500,
        'total_unlocked': 400,
        'total_pending': 100,
        'total_redeemed': 150,
        'updated_at': '2026-02-19T10:00:00.000Z',
      };
      final ws = WalletSummary.fromJson(json);
      expect(ws.earnedTotal, 500);
      expect(ws.unlockedTotal, 400);
      expect(ws.pendingTotal, 100);
      expect(ws.redeemedTotal, 150);
      expect(ws.availableBalance, 250);
    });

    test('fromJson falls back to legacy earned_* column names', () {
      final json = {
        'user_id': 'x',
        'earned_total': 200,
        'unlocked_total': 180,
        'pending_total': 20,
        'redeemed_total': 50,
        'updated_at': '2026-02-19T10:00:00.000Z',
      };
      final ws = WalletSummary.fromJson(json);
      expect(ws.earnedTotal, 200);
      expect(ws.unlockedTotal, 180);
    });

    test('fromJson defaults null amounts to 0', () {
      final json = {
        'user_id': 'y',
        'updated_at': '2026-02-19T10:00:00.000Z',
      };
      final ws = WalletSummary.fromJson(json);
      expect(ws.earnedTotal, 0);
      expect(ws.availableBalance, 0);
    });

    test('fromJson parses updatedAt correctly', () {
      final json = {
        'user_id': 'z',
        'updated_at': '2026-02-19T15:30:00.000Z',
      };
      final ws = WalletSummary.fromJson(json);
      expect(ws.updatedAt.year, 2026);
      expect(ws.updatedAt.month, 2);
      expect(ws.updatedAt.day, 19);
    });

    test('availableBalance is 0 when redeemedTotal >= unlockedTotal', () {
      final ws = WalletSummary(
        userId: 'u',
        earnedTotal: 100,
        unlockedTotal: 100,
        pendingTotal: 0,
        redeemedTotal: 100,
        updatedAt: DateTime.now(),
      );
      expect(ws.availableBalance, 0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // WalletTransaction domain model
  // ───────────────────────────────────────────────────────────────────────────

  group('WalletTransaction', () {
    test('fromJson parses credit type correctly', () {
      final json = {
        'id': 'txn-1',
        'user_id': 'u1',
        'amount': 100,
        'type': 'credit',
        'reason': 'trip_completion',
        'reference_id': 'trip-001',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.type, 'credit');
      expect(tx.amount, 100);
      expect(tx.signedAmount, 100);
      expect(tx.walletState, WalletValueState.earned);
      expect(tx.referenceId, 'trip-001');
    });

    test('fromJson parses debit type correctly', () {
      final json = {
        'id': 'txn-2',
        'user_id': 'u1',
        'amount': 50,
        'type': 'debit',
        'reason': 'reward_redemption',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.type, 'debit');
      expect(tx.signedAmount, -50);
      expect(tx.walletState, WalletValueState.redeemed);
      expect(tx.referenceId, isNull);
    });

    test('_normaliseType maps legacy redeemed -> debit', () {
      final json = {
        'id': 'txn-3',
        'user_id': 'u1',
        'amount': 25,
        'state': 'redeemed', // legacy field name
        'reason': 'legacy',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.type, 'debit');
      expect(tx.signedAmount, -25);
    });

    test('_normaliseType maps legacy earned -> credit', () {
      final json = {
        'id': 'txn-4',
        'user_id': 'u1',
        'amount': 75,
        'state': 'earned',
        'reason': 'legacy',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.type, 'credit');
      expect(tx.signedAmount, 75);
    });

    test('amount is always positive (abs applied)', () {
      final json = {
        'id': 'txn-5',
        'user_id': 'u1',
        'amount': -200,
        'type': 'credit',
        'reason': 'test',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.amount, 200);
    });

    test('reason defaults to empty string when absent', () {
      final json = {
        'id': 'txn-6',
        'user_id': 'u1',
        'amount': 10,
        'type': 'credit',
        'created_at': '2026-02-19T10:00:00.000Z',
      };
      final tx = WalletTransaction.fromJson(json);
      expect(tx.reason, '');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ActionType enum
  // ───────────────────────────────────────────────────────────────────────────

  group('ActionType enum', () {
    test('fromString maps all gamification-driven types', () {
      expect(ActionType.fromString('recover_streak'), ActionType.recoverStreak);
      expect(
        ActionType.fromString('complete_mission'),
        ActionType.completeMission,
      );
      expect(ActionType.fromString('start_streak'), ActionType.startStreak);
    });

    test('fromString maps all profile/engagement types', () {
      expect(ActionType.fromString('take_ride'), ActionType.takeRide);
      expect(
        ActionType.fromString('complete_profile'),
        ActionType.completeProfile,
      );
      expect(ActionType.fromString('invite_friend'), ActionType.inviteFriend);
      expect(ActionType.fromString('rate_past_ride'), ActionType.ratePastRide);
      expect(ActionType.fromString('join_community'), ActionType.joinCommunity);
    });

    test('fromString falls back to takeRide for unknown value', () {
      expect(ActionType.fromString('unknown_action'), ActionType.takeRide);
    });

    test('all ActionType values have non-empty keys and labels', () {
      for (final type in ActionType.values) {
        expect(type.key, isNotEmpty);
        expect(type.labelEn, isNotEmpty);
        expect(type.labelAr, isNotEmpty);
      }
    });

    test('label() returns labelAr when isRtl=true', () {
      expect(
        ActionType.recoverStreak.label(isRtl: true),
        ActionType.recoverStreak.labelAr,
      );
    });

    test('label() returns labelEn when isRtl=false', () {
      expect(
        ActionType.completeMission.label(isRtl: false),
        ActionType.completeMission.labelEn,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // NextBestAction domain model
  // ───────────────────────────────────────────────────────────────────────────

  group('NextBestAction', () {
    NextBestAction makeNba({
      ActionType type = ActionType.startStreak,
      DateTime? expiresAt,
      String? reason,
      double? confidenceScore,
    }) =>
        NextBestAction(
          actionType: type,
          title: 'Start a new streak',
          titleAr: 'ابدأ سلسلة',
          subtitle: 'Complete a trip today',
          subtitleAr: 'أتمّ رحلة اليوم',
          potentialXp: 25,
          deepLink: '/trips/new',
          expiresAt: expiresAt,
          reason: reason,
          confidenceScore: confidenceScore,
        );

    test('isExpired is false for null expiresAt', () {
      expect(makeNba().isExpired, isFalse);
    });

    test('isExpired is true when expiresAt is in the past', () {
      final nba = makeNba(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(nba.isExpired, isTrue);
    });

    test('isExpired is false when expiresAt is in the future', () {
      final nba = makeNba(
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      );
      expect(nba.isExpired, isFalse);
    });

    test('localizedTitle returns titleAr for isRtl=true', () {
      expect(makeNba().localizedTitle(isRtl: true), 'ابدأ سلسلة');
    });

    test('localizedTitle returns title for isRtl=false', () {
      expect(makeNba().localizedTitle(isRtl: false), 'Start a new streak');
    });

    test('fromJson parses recover_streak action from edge function response',
        () {
      final json = {
        'action_type': 'recover_streak',
        'title_en': 'Recover your streak!',
        'title_ar': 'استعد سلسلتك!',
        'subtitle_en': '3 more to complete',
        'subtitle_ar': '٣ للإكمال',
        'potential_xp': 50,
        'deep_link': '/trips/new',
        'expires_at': '2030-02-20T12:00:00.000Z',
        'reason': 'streak_in_grace',
        'confidence_score': 0.95,
      };
      final nba = NextBestAction.fromJson(json);
      expect(nba.actionType, ActionType.recoverStreak);
      expect(nba.reason, 'streak_in_grace');
      expect(nba.confidenceScore, closeTo(0.95, 0.001));
      expect(nba.potentialXp, 50);
      expect(nba.isExpired, isFalse);
    });

    test('fromJson parses complete_mission with null expires_at', () {
      final json = {
        'action_type': 'complete_mission',
        'title_en': 'Complete 3 trips',
        'title_ar': 'أكمل 3 رحلات',
        'subtitle_en': '1 more to go',
        'subtitle_ar': '١ للإكمال',
        'potential_xp': 100,
        'deep_link': null,
        'expires_at': null,
        'reason': 'mission_near_complete',
        'confidence_score': 0.87,
      };
      final nba = NextBestAction.fromJson(json);
      expect(nba.actionType, ActionType.completeMission);
      expect(nba.expiresAt, isNull);
      expect(nba.isExpired, isFalse);
    });

    test('fromJson handles missing reason and confidenceScore gracefully', () {
      final json = {
        'action_type': 'start_streak',
        'title_en': 'Start a new streak',
        'title_ar': '',
        'subtitle_en': '',
        'subtitle_ar': '',
        'potential_xp': 25,
      };
      final nba = NextBestAction.fromJson(json);
      expect(nba.reason, isNull);
      expect(nba.confidenceScore, isNull);
    });

    test('fromJson falls back legacy title field when title_en absent', () {
      final json = {
        'action_type': 'take_ride',
        'title': 'Take a Ride',
        'title_ar': 'خذ رحلة',
        'subtitle': 'Book now',
        'subtitle_ar': 'احجز الآن',
        'potential_xp': 10,
      };
      final nba = NextBestAction.fromJson(json);
      expect(nba.title, 'Take a Ride');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // WalletValueState enum
  // ───────────────────────────────────────────────────────────────────────────

  group('WalletValueState enum', () {
    test('fromString maps all known values', () {
      expect(WalletValueState.fromString('earned'), WalletValueState.earned);
      expect(
        WalletValueState.fromString('unlocked'),
        WalletValueState.unlocked,
      );
      expect(WalletValueState.fromString('pending'), WalletValueState.pending);
      expect(
        WalletValueState.fromString('redeemed'),
        WalletValueState.redeemed,
      );
    });

    test('fromString falls back to pending for unknown value', () {
      expect(WalletValueState.fromString('unknown'), WalletValueState.pending);
    });

    test('all values have non-empty keys and labels', () {
      for (final v in WalletValueState.values) {
        expect(v.key, isNotEmpty);
        expect(v.labelEn, isNotEmpty);
        expect(v.labelAr, isNotEmpty);
      }
    });
  });
}
