import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khawi_flutter/features/trips/presentation/ride_marketplace_screen.dart';
import 'package:khawi_flutter/features/xp_ledger/presentation/xp_ledger_screen.dart';
import 'package:khawi_flutter/features/auth/presentation/nafath_verification_screen.dart';
import 'package:khawi_flutter/features/error/presentation/not_authorized_screen.dart';
import 'package:khawi_flutter/models/user_role.dart';

import '../test/nav/test_app_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Deep Links and Tabs Integration', () {
    testWidgets('Deep link passenger search and tab switching preserves state',
        (tester) async {
      final refresh = TestRefresh();
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/app/p/home/search',
          refresh: refresh,
        ),
      );
      await tester.pumpAndSettle();

      // Assert deep linked screen is visible
      expect(find.byType(RideMarketplaceScreen), findsOneWidget);

      // Switch tabs by icon to avoid locale-dependent label matching.
      final navBar = find.byType(NavigationBar);
      await tester
          .tap(find.descendant(of: navBar, matching: find.byIcon(Icons.bolt)));
      await tester.pumpAndSettle();

      expect(find.byType(XpLedgerScreen), findsOneWidget);

      // Switch back to Home
      await tester
          .tap(find.descendant(of: navBar, matching: find.byIcon(Icons.home)));
      await tester.pumpAndSettle();

      // Ensure we are back at the search screen (state preservation in ShellRoute)
      expect(find.byType(RideMarketplaceScreen), findsOneWidget);
    });

    testWidgets('Deep link driver queue: unverified -> verification gate',
        (tester) async {
      final refresh = TestRefresh();
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.driver,
          isVerified: false,
          initialLocation: '/app/d/queue',
          refresh: refresh,
        ),
      );
      await tester.pumpAndSettle();

      // Unverified drivers are forced through the verification gate.
      expect(find.byType(NafathVerificationScreen), findsOneWidget);
    });

    testWidgets('Deep link forbidden route -> not-authorized', (tester) async {
      final refresh = TestRefresh();
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/app/d/dashboard',
          refresh: refresh,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotAuthorizedScreen), findsOneWidget);
    });
  });
}
