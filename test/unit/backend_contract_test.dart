// Backend Contract Registry Tests
// Validates consistency and uniqueness of backend identifiers.

import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';

void main() {
  group('EdgeFn', () {
    test('all function names are non-empty', () {
      final functions = [
        EdgeFn.scoreMatches,
        EdgeFn.smartMatch,
        EdgeFn.bundleStops,
        EdgeFn.computeIncentives,
        EdgeFn.computeTrustScores,
        EdgeFn.moderateMessage,
        EdgeFn.detectFraud,
        EdgeFn.checkTripSafety,
        EdgeFn.verifyIdentity,
        EdgeFn.xpCalculate,
        EdgeFn.supportCopilot,
        EdgeFn.computeAreaIncentives,
        EdgeFn.predictAcceptance,
        EdgeFn.createCheckoutSession,
        EdgeFn.stripeWebhook,
        EdgeFn.etaEstimation,
        EdgeFn.predictDemand,
        EdgeFn.driverBehaviorScoring,
        EdgeFn.redeemReward,
        EdgeFn.getTrustState,
        EdgeFn.listUserBadges,
        EdgeFn.classifyXpBucket,
        EdgeFn.computeTrustTier,
        EdgeFn.evaluateBadges,
      ];

      for (final fn in functions) {
        expect(
          fn.isNotEmpty,
          true,
          reason: 'Function name should not be empty',
        );
      }
    });

    test('no duplicate function names', () {
      final functions = [
        EdgeFn.scoreMatches,
        EdgeFn.smartMatch,
        EdgeFn.bundleStops,
        EdgeFn.computeIncentives,
        EdgeFn.computeTrustScores,
        EdgeFn.moderateMessage,
        EdgeFn.detectFraud,
        EdgeFn.checkTripSafety,
        EdgeFn.verifyIdentity,
        EdgeFn.xpCalculate,
        EdgeFn.supportCopilot,
        EdgeFn.computeAreaIncentives,
        EdgeFn.predictAcceptance,
        EdgeFn.createCheckoutSession,
        EdgeFn.stripeWebhook,
        EdgeFn.etaEstimation,
        EdgeFn.predictDemand,
        EdgeFn.driverBehaviorScoring,
        EdgeFn.redeemReward,
        EdgeFn.getTrustState,
        EdgeFn.listUserBadges,
        EdgeFn.classifyXpBucket,
        EdgeFn.computeTrustTier,
        EdgeFn.evaluateBadges,
      ];

      final unique = functions.toSet();
      expect(
        unique.length,
        functions.length,
        reason: 'No duplicate function names',
      );
    });
  });

  group('DbTable', () {
    test('all table names are non-empty', () {
      final tables = [
        DbTable.profiles,
        DbTable.trips,
        DbTable.tripRequests,
        DbTable.profileWithTrust,
        DbTable.tripMessages,
        DbTable.tripLocations,
        DbTable.kids,
        DbTable.juniorRuns,
        DbTable.juniorRunEvents,
        DbTable.juniorRunLocations,
        DbTable.juniorDriverGrants,
        DbTable.juniorInviteCodes,
        DbTable.trustedDrivers,
        DbTable.sosEvents,
        DbTable.matchScores,
        DbTable.trustProfiles,
        DbTable.areaIncentives,
        DbTable.fraudFlags,
        DbTable.moderationEvents,
        DbTable.xpEvents,
        DbTable.xpRules,
        DbTable.userGamification,
        DbTable.rewards,
        DbTable.rewardRedemptions,
        DbTable.rewardsCatalog,
        DbTable.badgesCatalog,
        DbTable.userBadgesV2,
        DbTable.userTrustState,
        DbTable.trustEvents,
        DbTable.supportTickets,
        DbTable.supportAiOutputs,
        DbTable.featureFlags,
        DbTable.eventLog,
        DbTable.notifications,
      ];

      for (final table in tables) {
        expect(
          table.isNotEmpty,
          true,
          reason: 'Table name should not be empty',
        );
      }
    });

    test('no duplicate table names', () {
      final tables = [
        DbTable.profiles,
        DbTable.trips,
        DbTable.tripRequests,
        DbTable.profileWithTrust,
        DbTable.tripMessages,
        DbTable.tripLocations,
        DbTable.kids,
        DbTable.juniorRuns,
        DbTable.juniorRunEvents,
        DbTable.juniorRunLocations,
        DbTable.juniorDriverGrants,
        DbTable.juniorInviteCodes,
        DbTable.trustedDrivers,
        DbTable.sosEvents,
        DbTable.matchScores,
        DbTable.trustProfiles,
        DbTable.areaIncentives,
        DbTable.fraudFlags,
        DbTable.moderationEvents,
        DbTable.xpEvents,
        DbTable.xpRules,
        DbTable.userGamification,
        DbTable.rewards,
        DbTable.rewardRedemptions,
        DbTable.rewardsCatalog,
        DbTable.badgesCatalog,
        DbTable.userBadgesV2,
        DbTable.userTrustState,
        DbTable.trustEvents,
        DbTable.supportTickets,
        DbTable.supportAiOutputs,
        DbTable.featureFlags,
        DbTable.eventLog,
        DbTable.notifications,
      ];

      final unique = tables.toSet();
      expect(unique.length, tables.length, reason: 'No duplicate table names');
    });

    test('table names follow snake_case convention', () {
      final tables = [
        DbTable.profiles,
        DbTable.trips,
        DbTable.tripRequests,
        DbTable.rewardsCatalog,
        DbTable.userTrustState,
      ];

      for (final table in tables) {
        expect(
          table,
          matches(RegExp(r'^[a-z][a-z0-9_]*$')),
          reason: '$table should be snake_case',
        );
      }
    });
  });
}
