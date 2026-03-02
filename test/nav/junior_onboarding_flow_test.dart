import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_intro_screen.dart';
import 'package:khawi_flutter/features/junior/presentation/kids_ride_safety_screen.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_role_selection_screen.dart';
import 'package:khawi_flutter/features/junior/presentation/kids_ride_hub_screen.dart';
import 'package:khawi_flutter/models/user_role.dart';

import '../nav/test_app_builder.dart';

void main() {
  group('Junior onboarding pipeline', () {
    testWidgets('junior intro screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.junior,
          initialLocation: '/app/j/splash',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(JuniorIntroScreen), findsOneWidget);
    });

    testWidgets('junior safety screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.junior,
          initialLocation: '/app/j/safety',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KidsRideSafetyScreen), findsOneWidget);
    });

    testWidgets('junior role selection screen renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.junior,
          initialLocation: '/app/j/role',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(JuniorRoleSelectionScreen), findsOneWidget);
    });

    testWidgets('junior hub renders', (tester) async {
      await tester.pumpWidget(
        buildRealTestApp(
          onboardingDone: true,
          isAuthed: true,
          role: UserRole.junior,
          initialLocation: '/app/j/hub',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KidsRideHubScreen), findsOneWidget);
    });
  });
}
