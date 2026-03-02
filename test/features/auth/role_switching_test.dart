import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khawi_flutter/features/auth/data/auth_repo.dart';
import 'package:khawi_flutter/features/profile/data/profile_repo.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/features/requests/data/requests_repo.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:mockito/annotations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Generate Mocks
@GenerateMocks([GoRouter, ProfileRepo, AuthRepo])
import 'role_switching_test.mocks.dart';

/// Mock notifier for onboarding that returns immediate value
class _MockOnboardingNotifier extends OnboardingDoneNotifier {
  final bool _value;
  _MockOnboardingNotifier(this._value);

  @override
  Future<bool> build() async => _value;

  @override
  Future<void> setDone(bool done) async {
    state = AsyncData(done);
  }
}

class _MockActiveRoleNotifier extends ActiveRoleNotifier {
  final UserRole? _role;
  _MockActiveRoleNotifier(this._role);

  @override
  UserRole? build() => _role;
}

class _MockRequestsRepo extends Fake implements RequestsRepo {
  @override
  Stream<List<TripRequest>> watchSentRequests(String? uid) => Stream.value([]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper to pump app with overrides
  Future<void> pumpRouterApp(
    WidgetTester tester, {
    required UserRole? role,
    bool isVerified = true,
    bool authed = true,
    bool onboardingDone = true,
  }) async {
    const mockUser = User(
      id: '123',
      email: 'test@a.b',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
    );
    final mockSession =
        Session(accessToken: 'abc', tokenType: 'bearer', user: mockUser);

    final profile = role == null
        ? null
        : Profile(
            id: '123',
            fullName: 'Test User',
            role: role,
            isPremium: false,
            isVerified: isVerified,
            totalXp: 0,
            redeemableXp: 0,
          );

    // Pre-accept safety disclaimer to prevent dialog from showing
    // (the dialog requires full localization context)
    SharedPreferences.setMockInitialValues({
      'khawi_safety_disclaimer_v1_passenger_accepted': true,
      'khawi_safety_disclaimer_v1_driver_accepted': true,
      'khawi_safety_disclaimer_v1_junior_accepted': true,
    });

    // We use the real app router but override state providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => authed ? Stream.value(mockSession) : Stream.value(null),
          ),
          myProfileProvider.overrideWith(
            (ref) => Stream.value(
              profile ??
                  const Profile(
                    id: '123',
                    fullName: '',
                    role: UserRole.passenger,
                    isPremium: false,
                    isVerified: false,
                    totalXp: 0,
                    redeemableXp: 0,
                  ),
            ),
          ),
          profileRepoProvider.overrideWith((ref) => MockProfileRepo()),
          authRepoProvider.overrideWith((ref) => MockAuthRepo()),
          requestsRepoProvider.overrideWith((ref) => _MockRequestsRepo()),
          roleSelectionCompletedProvider.overrideWith((ref) => authed),
          activeRoleProvider.overrideWith(() => _MockActiveRoleNotifier(role)),
          splashWaitProvider.overrideWith((ref) => Future.value()),
          // Must override onboardingDoneProvider to avoid SharedPreferences async issues
          onboardingDoneProvider
              .overrideWith(() => _MockOnboardingNotifier(onboardingDone)),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: router,
              // Keep tests deterministic regardless of host/device locale.
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
    // Avoid long hangs: 5-second step duration can stretch to minutes.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  group('Role Switching Integration Tests', () {
    testWidgets('Passenger lands on Passenger Home by default', (tester) async {
      // Suppress layout overflow errors common in test shell navigation
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.toString();
        if (msg.contains('overflowed') || msg.contains('overflow')) {
          return; // Ignore overflow in test environment
        }
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await pumpRouterApp(tester, role: UserRole.passenger);
      // Verify we are at Home (Bottom Nav Icon — shell uses Icons.home)
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('Unauthed goes to Login', (tester) async {
      await pumpRouterApp(tester, role: null, authed: false);
      // Verify Login Screen (assuming it has specific text or widget)
      // LoginScreen usually has "Login" text or specific button
      expect(find.textContaining('Login'), findsOneWidget);
    });
  });
}
