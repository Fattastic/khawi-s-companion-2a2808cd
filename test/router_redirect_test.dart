import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';

Profile _mockProfile({
  required String id,
  required UserRole role,
  bool isPremium = false,
  bool isVerified = false,
}) =>
    Profile(
      id: id,
      fullName: 'Test User',
      role: role,
      isPremium: isPremium,
      isVerified: isVerified,
      redeemableXp: 100,
      totalXp: 500,
      avatarUrl: null,
    );

Session _mockSession(String id) => Session(
      accessToken: 'test_token',
      tokenType: 'bearer',
      user: User(
        id: id,
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

String? _redirectFor({
  required String path,
  String? routeName,
  Map<String, String> pathParameters = const {},
  Session? session,
  Profile? profile,
  bool onboardingDone = true,
  UserRole? activeRole,
}) {
  return debugRedirectForTest(
    auth: AsyncValue.data(session),
    profile: AsyncValue.data(
      profile ?? _mockProfile(id: 'u1', role: UserRole.passenger),
    ),
    onboardingDone: AsyncValue.data(onboardingDone),
    activeRole: activeRole,
    path: path,
    routeName: routeName,
    pathParameters: pathParameters,
  );
}

void main() {
  group('Router Redirect Logic', () {
    test('unauthenticated user should redirect to login', () {
      final redirectTo = _redirectFor(
        path: Routes.passengerHome,
        session: null,
        onboardingDone: true,
      );
      expect(redirectTo, equals(Routes.authLogin));
    });

    test('authenticated passenger can access passenger home', () {
      final redirectTo = _redirectFor(
        path: Routes.passengerHome,
        session: _mockSession('p1'),
        profile: _mockProfile(id: 'p1', role: UserRole.passenger),
        activeRole: UserRole.passenger,
      );
      expect(redirectTo, isNull);
    });

    test(
        'non-premium user accessing shared redeem should redirect to subscription',
        () {
      final redirectTo = _redirectFor(
        path: Routes.sharedRedeem,
        session: _mockSession('p1'),
        profile:
            _mockProfile(id: 'p1', role: UserRole.passenger, isPremium: false),
        activeRole: UserRole.passenger,
      );
      expect(redirectTo, equals(Routes.subscription));
    });

    test('driver on shared profile should redirect to driver profile', () {
      final redirectTo = _redirectFor(
        path: Routes.sharedProfile,
        session: _mockSession('d1'),
        profile:
            _mockProfile(id: 'd1', role: UserRole.driver, isVerified: true),
        activeRole: UserRole.driver,
      );
      expect(redirectTo, equals(Routes.driverProfile));
    });

    test('active role null still routes to role selection gate', () {
      final redirectTo = _redirectFor(
        path: Routes.authRole,
        session: _mockSession('d1'),
        profile:
            _mockProfile(id: 'd1', role: UserRole.driver, isVerified: true),
        activeRole: null,
      );
      expect(redirectTo, isNull);
    });

    test('active role takes precedence over mismatching profile role', () {
      final redirectTo = _redirectFor(
        path: Routes.authRole,
        session: _mockSession('d2'),
        profile:
            _mockProfile(id: 'd2', role: UserRole.driver, isVerified: true),
        activeRole: UserRole.junior,
      );
      expect(redirectTo, equals(Routes.juniorHub));
    });
  });

  group('Legacy and shared alias redirects', () {
    test(
        'passenger hitting legacy driver planner should stay in passenger home',
        () {
      final redirectTo = _redirectFor(
        path: '/driver/planner',
        session: _mockSession('p1'),
        profile: _mockProfile(id: 'p1', role: UserRole.passenger),
        activeRole: UserRole.passenger,
      );
      expect(redirectTo, equals(Routes.passengerHome));
    });

    test(
        'driver hitting legacy passenger search should stay in driver dashboard',
        () {
      final redirectTo = _redirectFor(
        path: '/passenger/search',
        session: _mockSession('d1'),
        profile:
            _mockProfile(id: 'd1', role: UserRole.driver, isVerified: true),
        activeRole: UserRole.driver,
      );
      expect(redirectTo, equals(Routes.driverDashboard));
    });

    test('junior hitting shared challenges should redirect to junior rewards',
        () {
      final redirectTo = _redirectFor(
        path: Routes.sharedChallenges,
        session: _mockSession('j1'),
        profile: _mockProfile(id: 'j1', role: UserRole.junior),
        activeRole: UserRole.junior,
      );
      expect(redirectTo, equals(Routes.juniorRewards));
    });
  });

  group('Route Constants', () {
    test('all main routes are defined', () {
      expect(Routes.authLogin, isNotEmpty);
      expect(Routes.passengerHome, isNotEmpty);
      expect(Routes.driverDashboard, isNotEmpty);
      expect(Routes.juniorHub, isNotEmpty);

      expect(Routes.subscription, isNotEmpty);
      expect(Routes.notAuthorized, isNotEmpty);
    });
  });
}
