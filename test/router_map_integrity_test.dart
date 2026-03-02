import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/app/routes.dart';

void main() {
  group('Router map integrity', () {
    test('canonical route constants are unique and absolute', () {
      const canonicalRoutes = <String>[
        Routes.splash,
        Routes.onboarding,
        Routes.authLogin,
        Routes.authEmail,
        Routes.authVerify,
        Routes.authRole,
        Routes.authCallback,
        Routes.profileEnrichment,
        Routes.verification,
        Routes.subscription,
        Routes.passengerHome,
        Routes.passengerSearch,
        Routes.passengerBooking,
        Routes.passengerScan,
        Routes.passengerXpLedger,
        Routes.passengerRewards,
        Routes.passengerProfile,
        Routes.driverDashboard,
        Routes.driverQueue,
        Routes.driverRewards,
        Routes.driverProfile,
        Routes.driverPlanner,
        Routes.driverRegularTrips,
        Routes.driverInstantQr,
        Routes.juniorIntro,
        Routes.juniorSafety,
        Routes.juniorRoleSelection,
        Routes.juniorHub,
        Routes.juniorCarpool,
        Routes.juniorRewards,
        Routes.juniorTracking,
        Routes.juniorMore,
        Routes.juniorAppointedDash,
        Routes.livePassenger,
        Routes.liveDriver,
        Routes.liveJunior,
        Routes.liveAppointed,
        Routes.chat,
        Routes.sharedSubscription,
        Routes.sharedRedeem,
        Routes.sharedNotifications,
        Routes.sharedProfile,
        Routes.sharedRewards,
        Routes.sharedChallenges,
        Routes.referral,
        Routes.notFound,
        Routes.notAuthorized,
        Routes.devBackendDiagnostics,
      ];

      final unique = canonicalRoutes.toSet();
      expect(unique.length, canonicalRoutes.length);
      for (final route in canonicalRoutes) {
        expect(route, startsWith('/'));
      }
    });

    test('role route prefixes follow app convention', () {
      const passengerRoutes = <String>[
        Routes.passengerHome,
        Routes.passengerSearch,
        Routes.passengerBooking,
        Routes.passengerScan,
        Routes.passengerXpLedger,
        Routes.passengerRewards,
        Routes.passengerProfile,
      ];
      const driverRoutes = <String>[
        Routes.driverDashboard,
        Routes.driverQueue,
        Routes.driverRewards,
        Routes.driverProfile,
        Routes.driverPlanner,
        Routes.driverRegularTrips,
        Routes.driverInstantQr,
      ];
      const juniorRoutes = <String>[
        Routes.juniorIntro,
        Routes.juniorSafety,
        Routes.juniorRoleSelection,
        Routes.juniorHub,
        Routes.juniorCarpool,
        Routes.juniorRewards,
        Routes.juniorTracking,
        Routes.juniorMore,
        Routes.juniorAppointedDash,
      ];

      for (final route in passengerRoutes) {
        expect(route, startsWith('/app/p/'));
      }
      for (final route in driverRoutes) {
        expect(route, startsWith('/app/d/'));
      }
      for (final route in juniorRoutes) {
        expect(route, startsWith('/app/j/'));
      }
    });

    test('dynamic path helpers generate concrete paths', () {
      const tripId = 'trip-123';
      expect(Routes.livePassengerPath(tripId), '/live/passenger/$tripId');
      expect(Routes.liveDriverPath(tripId), '/live/driver/$tripId');
      expect(Routes.liveJuniorPath(tripId), '/live/junior/$tripId');
      expect(Routes.liveAppointedPath(tripId), '/live/appointed/$tripId');
      expect(Routes.chatPath(tripId), '/chat/$tripId');
      expect(Routes.passengerPostRidePath(tripId),
          '/app/p/home/post-ride/$tripId',);
    });
  });
}
