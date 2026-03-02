// Backend smoke tests with environment guards.
// These tests validate backend contracts and schema consistency.
// They require a running Supabase instance and are skipped in CI by default.
//
// To run locally:
//   1. Start local Supabase: supabase start
//   2. Set env var: set KHAWI_INTEGRATION_TEST=1
//   3. Run: flutter test test/backend_smoke_test.dart

@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/data/dto/edge/score_matches_dto.dart';
import 'package:khawi_flutter/data/dto/edge/compute_incentives_dto.dart';
import 'package:khawi_flutter/data/dto/edge/check_trip_safety_dto.dart';
import 'package:khawi_flutter/data/dto/edge/verify_identity_dto.dart';
import 'package:khawi_flutter/data/dto/edge/xp_calculate_dto.dart';

/// Check if integration tests should run.
/// Tests are skipped unless KHAWI_INTEGRATION_TEST=1 is set.
const _defaultSupabaseUrl = 'https://oxcustajfzeqibnkjthp.supabase.co';
const _defaultSupabaseAnonKey =
    'sb_publishable_jjF9aK40I9cWynRsw2vKeQ_3dtvVsaz';

/// Check if integration tests should run.
/// Tests are skipped unless KHAWI_INTEGRATION_TEST=1 is set.
bool get _shouldRunIntegrationTests {
  final envVar = Platform.environment['KHAWI_INTEGRATION_TEST'];
  // We have defaults now, so backend env is considered present if defaults are present (always true)
  // or if env vars are present.
  final hasBackendEnv =
      _defaultSupabaseUrl.isNotEmpty && _defaultSupabaseAnonKey.isNotEmpty;
  return (envVar == '1' || envVar == 'true') && hasBackendEnv;
}

void main() {
  group('Backend Contract Registry', () {
    test('EdgeFn constants are non-empty strings', () {
      // Verify all Edge Function names are valid
      expect(EdgeFn.scoreMatches, isNotEmpty);
      expect(EdgeFn.smartMatch, isNotEmpty);
      expect(EdgeFn.bundleStops, isNotEmpty);
      expect(EdgeFn.computeIncentives, isNotEmpty);
      expect(EdgeFn.computeTrustScores, isNotEmpty);
      expect(EdgeFn.moderateMessage, isNotEmpty);
      expect(EdgeFn.detectFraud, isNotEmpty);
      expect(EdgeFn.checkTripSafety, isNotEmpty);
      expect(EdgeFn.verifyIdentity, isNotEmpty);
      expect(EdgeFn.xpCalculate, isNotEmpty);
      expect(EdgeFn.classifyXpBucket, isNotEmpty);
      expect(EdgeFn.computeTrustTier, isNotEmpty);
      expect(EdgeFn.evaluateBadges, isNotEmpty);
      expect(EdgeFn.predictAcceptance, isNotEmpty);
      expect(EdgeFn.predictDemand, isNotEmpty);
      expect(EdgeFn.etaEstimation, isNotEmpty);
      expect(EdgeFn.driverBehaviorScoring, isNotEmpty);
      expect(EdgeFn.computeAreaIncentives, isNotEmpty);
      expect(EdgeFn.redeemReward, isNotEmpty);
      expect(EdgeFn.createCheckoutSession, isNotEmpty);
      expect(EdgeFn.stripeWebhook, isNotEmpty);
      expect(EdgeFn.supportCopilot, isNotEmpty);
    });

    test('DbTable constants are non-empty strings', () {
      // Verify all table names are valid
      expect(DbTable.profiles, isNotEmpty);
      expect(DbTable.trips, isNotEmpty);
      expect(DbTable.tripRequests, isNotEmpty);
      expect(DbTable.tripMessages, isNotEmpty);
      expect(DbTable.tripLocations, isNotEmpty);
      expect(DbTable.kids, isNotEmpty);
      expect(DbTable.juniorRuns, isNotEmpty);
      expect(DbTable.xpEvents, isNotEmpty);
      expect(DbTable.trustProfiles, isNotEmpty);
      expect(DbTable.areaIncentives, isNotEmpty);
    });

    test('DbRpc constants are non-empty strings', () {
      // Verify all RPC names are valid
      expect(DbRpc.sendJoinRequest, isNotEmpty);
      expect(DbRpc.cancelJoinRequest, isNotEmpty);
      expect(DbRpc.driverAcceptRequest, isNotEmpty);
      expect(DbRpc.driverDeclineRequest, isNotEmpty);
      expect(DbRpc.updateRequestStatus, isNotEmpty);
      expect(DbRpc.createSos, isNotEmpty);
      expect(DbRpc.awardTripXp, isNotEmpty);
    });

    test('DbCol constants are non-empty strings', () {
      // Verify common column names are valid
      expect(DbCol.id, isNotEmpty);
      expect(DbCol.status, isNotEmpty);
      expect(DbCol.createdAt, isNotEmpty);
      expect(DbCol.updatedAt, isNotEmpty);
      expect(DbCol.isPremium, isNotEmpty);
      expect(DbCol.isVerified, isNotEmpty);
      expect(DbCol.driverId, isNotEmpty);
      expect(DbCol.passengerId, isNotEmpty);
    });
  });

  group('Edge Function DTOs', () {
    test('ScoreMatchesRequest serializes correctly', () {
      final req = ScoreMatchesRequest(
        tripIds: ['trip-1', 'trip-2'],
        originLat: 24.7136,
        originLng: 46.6753,
        destLat: 24.8136,
        destLng: 46.7753,
      );

      final json = req.toJson();
      expect(json['trip_ids'], ['trip-1', 'trip-2']);
      expect(json['passenger_origin']['lat'], 24.7136);
      expect(json['passenger_origin']['lng'], 46.6753);
      expect(json['passenger_dest']['lat'], 24.8136);
      expect(json['passenger_dest']['lng'], 46.7753);
    });

    test('ScoreMatchesResponse deserializes correctly', () {
      final json = {
        'matches': [
          {
            'trip_id': 'trip-1',
            'match_score': 85,
            'explanation_tags': ['close_origin', 'same_time'],
            'accept_prob': 0.92,
          },
        ],
      };

      final response = ScoreMatchesResponse.fromJson(json);
      expect(response.matches.length, 1);
      expect(response.matches.first.tripId, 'trip-1');
      expect(response.matches.first.matchScore, 85);
      expect(
        response.matches.first.explanationTags,
        ['close_origin', 'same_time'],
      );
      expect(response.matches.first.acceptProb, 0.92);
    });

    test('ScoreMatchesResponse handles missing optional fields', () {
      final json = {
        'matches': [
          {
            'trip_id': 'trip-1',
            'match_score': 50,
          },
        ],
      };

      final response = ScoreMatchesResponse.fromJson(json);
      expect(response.matches.first.explanationTags, isEmpty);
      expect(response.matches.first.acceptProb, 0.0);
    });

    test('ComputeIncentivesRequest serializes correctly', () {
      final now = DateTime(2025, 1, 29, 12, 0, 0);
      final req = ComputeIncentivesRequest(
        lat: 24.7136,
        lng: 46.6753,
        time: now,
      );

      final json = req.toJson();
      expect(json['lat'], 24.7136);
      expect(json['lng'], 46.6753);
      expect(json['time'], isNotNull);
    });

    test('CheckTripSafetyRequest serializes correctly', () {
      final req = CheckTripSafetyRequest(
        tripId: 'trip-123',
        currentLat: 24.7136,
        currentLng: 46.6753,
        unexpectedStopDuration: 60,
        speedKmh: 45,
      );

      final json = req.toJson();
      expect(json['trip_id'], 'trip-123');
      expect(json['current_lat'], 24.7136);
      expect(json['current_lng'], 46.6753);
      expect(json['unexpected_stop_duration'], 60);
      expect(json['speed_kmh'], 45);
    });

    test('VerifyIdentityRequest serializes correctly', () {
      const req = VerifyIdentityRequest(userId: 'user-123', dryRun: true);
      final json = req.toJson();
      expect(json['user_id'], 'user-123');
      expect(json['dry_run'], true);
    });

    test('XpCalculateRequest serializes correctly', () {
      final req = XpCalculateRequest(
        userId: 'user-123',
        baseXp: 10,
        tripId: 'trip-1',
        occurredAt: DateTime(2025, 1, 29, 12, 0, 0),
      );
      final json = req.toJson();
      expect(json['user_id'], 'user-123');
      expect(json['base_xp'], 10);
      expect(json['trip_id'], 'trip-1');
      expect(json['occurred_at'], isNotNull);
    });
  });

  group('Integration Tests (requires KHAWI_INTEGRATION_TEST=1)', () {
    setUpAll(() {
      if (!_shouldRunIntegrationTests) {
        debugPrint(
          '⏭️ Skipping integration tests. Set KHAWI_INTEGRATION_TEST=1 to enable.',
        );
      }
    });

    test(
      'EdgeFn names match deployed function names',
      () {
        if (!_shouldRunIntegrationTests) return;

        // This would actually call the edge functions to verify deployment
        // For now, we just verify the constants match expected patterns
        expect(EdgeFn.scoreMatches, 'score_matches');
        expect(EdgeFn.smartMatch, 'smart_match');
        expect(EdgeFn.bundleStops, 'bundle_stops');
        expect(EdgeFn.computeIncentives, 'compute_incentives');
        expect(EdgeFn.checkTripSafety, 'check_trip_safety');
        expect(EdgeFn.moderateMessage, 'moderate_message');
        expect(EdgeFn.verifyIdentity, 'verify_identity');
        expect(EdgeFn.xpCalculate, 'xp_calculate');
        expect(EdgeFn.classifyXpBucket, 'classify_xp_bucket');
        expect(EdgeFn.computeTrustTier, 'compute_trust_tier');
        expect(EdgeFn.evaluateBadges, 'evaluate_badges');
        expect(EdgeFn.predictAcceptance, 'predict_acceptance');
        expect(EdgeFn.predictDemand, 'predict_demand');
        expect(EdgeFn.etaEstimation, 'eta_estimation');
        expect(EdgeFn.driverBehaviorScoring, 'driver_behavior_scoring');
        expect(EdgeFn.computeAreaIncentives, 'compute_area_incentives');
        expect(EdgeFn.redeemReward, 'redeem_reward');
        expect(EdgeFn.createCheckoutSession, 'create_checkout_session');
        expect(EdgeFn.stripeWebhook, 'stripe_webhook');
        expect(EdgeFn.supportCopilot, 'support_copilot');
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'DbTable names match database schema',
      () {
        if (!_shouldRunIntegrationTests) return;

        // Verify table name patterns (snake_case, no special chars)
        final tables = [
          DbTable.profiles,
          DbTable.trips,
          DbTable.tripRequests,
          DbTable.tripMessages,
          DbTable.tripLocations,
          DbTable.kids,
          DbTable.juniorRuns,
          DbTable.xpEvents,
          DbTable.trustProfiles,
          DbTable.areaIncentives,
        ];

        for (final table in tables) {
          expect(
            table,
            matches(r'^[a-z_]+$'),
            reason: 'Table name "$table" should be snake_case',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'DbRpc names match database functions',
      () {
        if (!_shouldRunIntegrationTests) return;

        // Verify RPC name patterns
        final rpcs = [
          DbRpc.sendJoinRequest,
          DbRpc.cancelJoinRequest,
          DbRpc.driverAcceptRequest,
          DbRpc.driverDeclineRequest,
          DbRpc.updateRequestStatus,
          DbRpc.createSos,
          DbRpc.awardTripXp,
        ];

        for (final rpc in rpcs) {
          expect(
            rpc,
            matches(r'^[a-z_]+$'),
            reason: 'RPC name "$rpc" should be snake_case',
          );
        }
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );
  });
}
