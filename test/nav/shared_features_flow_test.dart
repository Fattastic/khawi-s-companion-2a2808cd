import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/notifications/presentation/notifications_screen.dart';
import 'package:khawi_flutter/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:khawi_flutter/features/promo_codes/presentation/promo_codes_screen.dart';
import 'package:khawi_flutter/features/carbon/presentation/carbon_tracker_screen.dart';
import 'package:khawi_flutter/features/smart_commute/presentation/smart_commute_screen.dart';
import 'package:khawi_flutter/features/referral/presentation/referral_screen.dart';
import 'package:khawi_flutter/models/user_role.dart';

import '../nav/test_app_builder.dart';

void main() {
  group('Shared features accessible from passenger role', () {
    testWidgets('notifications screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/shared/notifications',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('leaderboard screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/shared/leaderboard',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });

    testWidgets('promo codes screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/shared/promo-codes',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PromoCodesScreen), findsOneWidget);
    });

    testWidgets('carbon tracker screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/shared/carbon',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CarbonTrackerScreen), findsOneWidget);
    });

    testWidgets('smart commute screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/shared/smart-commute',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SmartCommuteScreen), findsOneWidget);
    });

    testWidgets('referral screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/referral',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReferralScreen), findsOneWidget);
    });
  });

  group('Shared features accessible from driver role', () {
    testWidgets('notifications screen renders for driver', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.driver,
          isVerified: true,
          initialLocation: '/shared/notifications',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('leaderboard screen renders for driver', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.driver,
          isVerified: true,
          initialLocation: '/shared/leaderboard',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });
  });
}
