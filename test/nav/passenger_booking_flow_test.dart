import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/presentation/ride_marketplace_screen.dart';
import 'package:khawi_flutter/features/xp_ledger/presentation/xp_ledger_screen.dart';
import 'package:khawi_flutter/models/user_role.dart';

import '../nav/test_app_builder.dart';

void main() {
  group('Passenger core flow', () {
    testWidgets('lands on Home tab, navigates to search (marketplace)',
        (tester) async {
      // Set a tall surface to avoid RenderFlex overflow in the marketplace UI.
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/app/p/home/search',
        ),
      );
      // Use pump() — passenger shell screens may have ongoing timers (up to 5s).
      await tester.pump(const Duration(seconds: 6));

      expect(find.byType(RideMarketplaceScreen), findsOneWidget);

      // Dispose widget tree and drain pending microtasks/timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
    });

    testWidgets('XP Ledger screen via deep link', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.passenger,
          initialLocation: '/app/p/xp-ledger',
        ),
      );
      // Use pump() — XpLedgerScreen may trigger ongoing timers.
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(XpLedgerScreen), findsOneWidget);

      // Dispose widget tree to cancel any pending timers.
      await tester.pumpWidget(const SizedBox());
    });
  });
}
