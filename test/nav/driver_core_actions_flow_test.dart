import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/driver/presentation/ride_request_queue_screen.dart';
import 'package:khawi_flutter/features/trips/presentation/offer_ride/offer_ride_wizard.dart';
import 'package:khawi_flutter/models/user_role.dart';

import '../nav/test_app_builder.dart';

void main() {
  group('Driver core actions flow', () {
    testWidgets('driver queue renders from deep link', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.driver,
          isVerified: true,
          initialLocation: '/app/d/queue',
        ),
      );
      // Use pump() — screens in the driver shell may have ongoing timers (up to 5s).
      await tester.pump(const Duration(seconds: 6));

      expect(find.byType(RideRequestQueueScreen), findsOneWidget);

      // Dispose widget tree and drain pending microtasks/timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
    });

    testWidgets('offer ride wizard renders from deep link', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.driver,
          isVerified: true,
          initialLocation: '/app/d/dashboard/offer-ride',
        ),
      );
      // Use pump() — OfferRideWizard may have ongoing timers (up to 5s).
      await tester.pump(const Duration(seconds: 6));

      expect(find.byType(OfferRideWizard), findsOneWidget);

      // Dispose widget tree and drain pending microtasks/timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
    });
  });
}
