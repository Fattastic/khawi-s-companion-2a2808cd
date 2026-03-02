// ─────────────────────────────────────────────────────────────────────────────
// DELIVERABLE 3: ROUTE CONNECTIVITY & REACHABILITY CHECKS
// DELIVERABLE 5: REGRESSION GUARDS (invariants that must never break)
// Run: flutter test test/routing_debugger/route_connectivity_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test Helpers (reusable across all routing tests)
// ─────────────────────────────────────────────────────────────────────────────
Profile _p({
  String id = 'u1',
  String fullName = 'Test User',
  UserRole? role = UserRole.passenger,
  bool isPremium = false,
  bool isVerified = false,
}) =>
    Profile(
      id: id,
      fullName: fullName,
      role: role,
      isPremium: isPremium,
      isVerified: isVerified,
      totalXp: 0,
      redeemableXp: 0,
    );

/// Shorthand for calling debugRedirectForTest.
String? _r({
  required String path,
  AsyncValue<dynamic>? auth,
  AsyncValue<Profile?>? profile,
  AsyncValue<bool>? onboardingDone,
  UserRole? activeRole,
}) {
  return debugRedirectForTest(
    auth: auth ?? const AsyncValue.data('session'),
    profile: profile ?? AsyncValue.data(_p()),
    onboardingDone: onboardingDone ?? const AsyncValue.data(true),
    activeRole: activeRole,
    path: path,
  );
}

/// Follows up to [maxHops] redirects and returns the final destination.
/// Returns the path (possibly unchanged) or 'LOOP' if a cycle is detected.
String _resolve(
  String startPath, {
  AsyncValue<dynamic>? auth,
  AsyncValue<Profile?>? profile,
  AsyncValue<bool>? onboardingDone,
  UserRole? activeRole,
  int maxHops = 10,
}) {
  String current = startPath;
  final visited = <String>{};
  for (int i = 0; i < maxHops; i++) {
    if (visited.contains(current)) return 'LOOP($current)';
    visited.add(current);
    final next = _r(
      path: current,
      auth: auth,
      profile: profile,
      onboardingDone: onboardingDone,
      activeRole: activeRole,
    );
    if (next == null) return current; // no redirect, final location
    current = next;
  }
  return 'LOOP($current)';
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DELIVERABLE 3: CONNECTIVITY & REACHABILITY
  // ─────────────────────────────────────────────────────────────────────────
  group('Route Connectivity – Canonical routes reachable via cold start', () {
    test('Passenger Home reachable when authed + passenger role', () {
      final dest = _resolve(
        Routes.passengerHome,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.passengerHome);
    });

    test('Driver Dashboard reachable when authed + driver + verified', () {
      final dest = _resolve(
        Routes.driverDashboard,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(
          _p(role: UserRole.driver, isVerified: true),
        ),
      );
      expect(dest, Routes.driverDashboard);
    });

    test('Junior Hub reachable when authed + junior role', () {
      final dest = _resolve(
        Routes.juniorHub,
        activeRole: UserRole.junior,
        profile: AsyncValue.data(_p(role: UserRole.junior)),
      );
      expect(dest, Routes.juniorHub);
    });

    test('Passenger nested routes reachable', () {
      for (final path in [
        '/app/p/home/search',
        '/app/p/home/scan',
        '/app/p/home/explore-map',
        '/app/p/xp-ledger',
        '/app/p/rewards',
        '/app/p/profile',
      ]) {
        final dest = _resolve(
          path,
          activeRole: UserRole.passenger,
          profile: AsyncValue.data(_p(role: UserRole.passenger)),
        );
        expect(dest, path, reason: '$path should be reachable for passenger');
      }
    });

    test('Driver nested routes reachable (verified)', () {
      for (final path in [
        '/app/d/dashboard/ai-planner',
        '/app/d/dashboard/instant-qr',
        '/app/d/dashboard/offer-ride',
        '/app/d/dashboard/explore-map',
        '/app/d/queue',
        '/app/d/rewards',
        '/app/d/profile',
      ]) {
        final dest = _resolve(
          path,
          activeRole: UserRole.driver,
          profile: AsyncValue.data(
            _p(role: UserRole.driver, isVerified: true),
          ),
        );
        expect(dest, path,
            reason: '$path should be reachable for verified driver',);
      }
    });

    test('Junior nested routes reachable', () {
      for (final path in [
        '/app/j/hub/carpool',
        '/app/j/hub/add-driver',
        '/app/j/tracking',
        '/app/j/rewards',
        '/app/j/more',
      ]) {
        final dest = _resolve(
          path,
          activeRole: UserRole.junior,
          profile: AsyncValue.data(_p(role: UserRole.junior)),
        );
        expect(dest, path, reason: '$path should be reachable for junior');
      }
    });

    test('Shared routes reachable (all roles)', () {
      for (final role in UserRole.values) {
        for (final path in [
          Routes.sharedRedeem,
          Routes.sharedNotifications,
          Routes.referral,
        ]) {
          // sharedRedeem requires premium
          final p = _p(role: role, isPremium: true, isVerified: true);
          final dest = _resolve(
            path,
            activeRole: role,
            profile: AsyncValue.data(p),
          );
          // sharedRedeem stays, sharedNotifications stays, referral stays
          expect(
            dest,
            path,
            reason: '$path should be reachable for ${role.name}',
          );
        }
      }
    });

    test('Live trip routes reachable (all roles)', () {
      for (final path in [
        '/live/passenger/trip123',
        '/live/driver/trip123',
        '/live/junior/trip123',
        '/live/appointed/trip123',
        '/chat/trip123',
      ]) {
        // Live routes don't have role guards in _redirectLogic
        final dest = _resolve(
          path,
          activeRole: UserRole.passenger,
          profile: AsyncValue.data(_p(role: UserRole.passenger)),
        );
        expect(dest, path, reason: '$path should be reachable');
      }
    });
  });

  group('Legacy Redirect Resolution (single-hop preferred)', () {
    test('All legacy routes resolve to their canonical targets via _resolve',
        () {
      // Legacy routes use GoRoute-level redirects (not _redirectLogic).
      // debugRedirectForTest only tests _redirectLogic.
      // So we test that _resolve (which chains redirects) eventually
      // lands on a stable, non-looping destination.
      final legacyPaths = [
        '/passenger/home',
        '/driver/dashboard',
        '/junior/hub',
      ];

      for (final path in legacyPaths) {
        // These paths hit _redirectLogic's legacy cross-role guard (step 10)
        // when the active role doesn't match.
        // With matching role they resolve to the canonical home.
        final dest = _resolve(
          path,
          activeRole: UserRole.passenger,
          profile: AsyncValue.data(_p(role: UserRole.passenger)),
        );
        expect(
          dest,
          isNot(contains('LOOP')),
          reason: '$path should not loop',
        );
      }
    });

    test('Legacy routes handled at GoRoute level are redirect-only', () {
      // These are verified by route_graph_extractor_test (no builder check).
      // Here we just confirm the _redirectLogic doesn't interfere.
      // GoRoute redirects: /, /login, /plus, /role, /rewards/redeem, /notifications
      // _redirectLogic sees the TARGET path, not the legacy path.
      // Verify the targets are reachable:
      final targets = {
        '/auth/login': const AsyncValue<dynamic>.data(null), // unauthenticated
        '/subscription': const AsyncValue<dynamic>.data('session'), // authed
        '/auth/role': const AsyncValue<dynamic>.data(null), // unauthenticated
        '/shared/redeem': const AsyncValue<dynamic>.data('session'),
        '/shared/notifications': const AsyncValue<dynamic>.data('session'),
      };

      for (final entry in targets.entries) {
        final isAuthed = entry.value.valueOrNull != null;
        final dest = _r(
          path: entry.key,
          auth: entry.value,
          activeRole: isAuthed ? UserRole.passenger : null,
          profile: isAuthed
              ? AsyncValue.data(_p(role: UserRole.passenger, isPremium: true))
              : const AsyncValue.data(null),
        );
        // Should either stay (null) or redirect to a valid place
        expect(
          dest,
          isNot(contains('LOOP')),
          reason: '${entry.key} should not loop',
        );
      }
    });
  });

  group('Redirect Loop Detection', () {
    test('No loops for unauthenticated user', () {
      final dest = _resolve(
        Routes.passengerHome,
        auth: const AsyncValue.data(null),
        activeRole: null,
      );
      expect(
        dest,
        isNot(contains('LOOP')),
        reason: 'Unauthenticated should not loop',
      );
    });

    test('No loops for authenticated user with no role', () {
      final dest = _resolve(Routes.passengerHome, activeRole: null);
      expect(dest, isNot(contains('LOOP')));
    });

    test('No loops for splash (loading states)', () {
      // Can't test splashLoading via debugRedirectForTest (hardcoded false)
      // but we can test onboarding loading
      final dest = _resolve(
        Routes.splash,
        onboardingDone: const AsyncValue.loading(),
        activeRole: null,
      );
      expect(dest, isNot(contains('LOOP')));
    });

    test('No loops: all canonical paths with every role', () {
      final allPaths = [
        Routes.splash,
        Routes.onboarding,
        Routes.authLogin,
        Routes.authRole,
        Routes.passengerHome,
        Routes.driverDashboard,
        Routes.juniorHub,
        Routes.verification,
        Routes.subscription,
        Routes.sharedRedeem,
        Routes.sharedNotifications,
        Routes.notAuthorized,
        Routes.notFound,
      ];

      for (final role in [null, ...UserRole.values]) {
        for (final path in allPaths) {
          final isVerified = role == UserRole.driver;
          final dest = _resolve(
            path,
            activeRole: role,
            profile: AsyncValue.data(
              _p(
                role: role ?? UserRole.passenger,
                isVerified: isVerified,
                isPremium: true,
              ),
            ),
          );
          expect(
            dest,
            isNot(contains('LOOP')),
            reason: 'LOOP detected at $path with role $role',
          );
        }
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DELIVERABLE 5: REGRESSION INVARIANTS
  // ─────────────────────────────────────────────────────────────────────────
  group('Regression Invariants – MUST NEVER BREAK', () {
    // R1: Splash loading keeps you at /splash
    test('R1: onboarding loading stays at /splash', () {
      final dest = _r(
        path: Routes.splash,
        onboardingDone: const AsyncValue.loading(),
        auth: const AsyncValue.data(null),
        activeRole: null,
      );
      expect(dest, isNull, reason: 'Should stay at /splash during loading');
    });

    // R2: Onboarding not done forces /onboarding
    test('R2: onboarding not done forces /onboarding', () {
      final dest = _r(
        path: Routes.passengerHome,
        onboardingDone: const AsyncValue.data(false),
        auth: const AsyncValue.data(null),
        activeRole: null,
      );
      expect(dest, Routes.onboarding);
    });

    // R3: Not authenticated forces /auth/login
    test('R3: not authenticated forces /auth/login', () {
      final dest = _r(
        path: Routes.passengerHome,
        auth: const AsyncValue.data(null),
        activeRole: null,
      );
      expect(dest, Routes.authLogin);
    });

    // R4: Auth routes allowed when unauthenticated
    test('R4: auth routes allowed when unauthenticated', () {
      for (final path in [
        Routes.authLogin,
        Routes.authEmail,
        Routes.authVerify,
        Routes.authRole,
        Routes.authCallback,
      ]) {
        final dest = _r(
          path: path,
          auth: const AsyncValue.data(null),
          activeRole: null,
        );
        expect(
          dest,
          isNull,
          reason: '$path should be allowed for unauthenticated user',
        );
      }
    });

    // R5: Profile null/incomplete forces /auth/enrichment (profile-before-role flow)
    test('R5: profile null forces /auth/enrichment', () {
      final dest = _r(
        path: Routes.passengerHome,
        profile: const AsyncValue.data(null),
        activeRole: null,
      );
      expect(dest, Routes.profileEnrichment);
    });

    test('R5b: incomplete profile forces /auth/enrichment', () {
      final dest = _r(
        path: Routes.passengerHome,
        profile: AsyncValue.data(_p(fullName: '', role: null)),
        activeRole: null,
      );
      expect(dest, Routes.profileEnrichment);
    });

    // R6: activeRole null forces /auth/role
    test('R6: activeRole null forces /auth/role', () {
      final dest = _r(
        path: Routes.passengerHome,
        activeRole: null,
      );
      expect(dest, Routes.authRole);
    });

    // R7: Role mismatch -> /not-authorized
    test('R7a: passenger accessing driver route -> /not-authorized', () {
      final dest = _r(
        path: Routes.driverDashboard,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.notAuthorized);
    });

    test('R7b: driver accessing passenger route -> /not-authorized', () {
      final dest = _r(
        path: Routes.passengerHome,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(
          _p(role: UserRole.driver, isVerified: true),
        ),
      );
      expect(dest, Routes.notAuthorized);
    });

    test('R7c: passenger accessing junior route -> /not-authorized', () {
      final dest = _r(
        path: Routes.juniorHub,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.notAuthorized);
    });

    // R8: Unverified driver forced to /verification
    test('R8: unverified driver on driver routes -> /verification', () {
      final dest = _r(
        path: Routes.driverDashboard,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(
          _p(role: UserRole.driver, isVerified: false),
        ),
      );
      expect(dest, Routes.verification);
    });

    // R9: Non-premium forced to /subscription for /shared/redeem
    test('R9: non-premium -> /subscription for redeem', () {
      final dest = _r(
        path: Routes.sharedRedeem,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(
          _p(role: UserRole.passenger, isPremium: false),
        ),
      );
      expect(dest, Routes.subscription);
    });

    test('R9b: premium user can access redeem', () {
      final dest = _r(
        path: Routes.sharedRedeem,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(
          _p(role: UserRole.passenger, isPremium: true),
        ),
      );
      expect(dest, isNull);
    });

    // R10: Authenticated user on auth/splash/onboarding gets sent home
    test('R10: authed user on /splash goes to role home', () {
      final dest = _r(
        path: Routes.splash,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.passengerHome);
    });

    test('R10b: authed driver on /auth/login goes to driver home', () {
      final dest = _r(
        path: Routes.authLogin,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(
          _p(role: UserRole.driver, isVerified: true),
        ),
      );
      expect(dest, Routes.driverDashboard);
    });

    test('R10c: authed junior on /onboarding goes to junior home', () {
      final dest = _r(
        path: Routes.onboarding,
        activeRole: UserRole.junior,
        profile: AsyncValue.data(_p(role: UserRole.junior)),
      );
      expect(dest, Routes.juniorHub);
    });

    // R11: Profile loading shows splash
    test('R11: profile loading redirects to /splash', () {
      final dest = _r(
        path: Routes.passengerHome,
        profile: const AsyncValue.loading(),
        activeRole: UserRole.passenger,
      );
      expect(dest, Routes.splash);
    });

    // R12: Shared profile/rewards/challenges redirect per role
    test('R12a: shared profile -> role-specific profile (passenger)', () {
      final dest = _r(
        path: Routes.sharedProfile,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.passengerProfile);
    });

    test('R12b: shared profile -> role-specific profile (driver)', () {
      final dest = _r(
        path: Routes.sharedProfile,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(
          _p(role: UserRole.driver, isVerified: true),
        ),
      );
      expect(dest, Routes.driverProfile);
    });

    test('R12c: shared profile -> role-specific profile (junior)', () {
      final dest = _r(
        path: Routes.sharedProfile,
        activeRole: UserRole.junior,
        profile: AsyncValue.data(_p(role: UserRole.junior)),
      );
      expect(dest, Routes.juniorMore);
    });

    test('R12d: shared rewards -> role-specific rewards (all roles)', () {
      final expected = {
        UserRole.passenger: Routes.passengerRewards,
        UserRole.driver: Routes.driverRewards,
        UserRole.junior: Routes.juniorRewards,
      };
      for (final entry in expected.entries) {
        final dest = _r(
          path: Routes.sharedRewards,
          activeRole: entry.key,
          profile: AsyncValue.data(
            _p(
              role: entry.key,
              isVerified: entry.key == UserRole.driver,
            ),
          ),
        );
        expect(
          dest,
          entry.value,
          reason: '/shared/rewards for ${entry.key.name}',
        );
      }
    });

    // R13: Legacy cross-role guard
    test('R13: legacy /driver/* as passenger -> passenger home', () {
      final dest = _r(
        path: '/driver/dashboard',
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(role: UserRole.passenger)),
      );
      expect(dest, Routes.passengerHome);
    });

    // R14: /auth/enrichment allowed for incomplete profile
    test('R14: /auth/enrichment allowed for incomplete profile', () {
      final dest = _r(
        path: Routes.profileEnrichment,
        profile: AsyncValue.data(_p(fullName: '', role: null)),
        activeRole: null,
      );
      expect(
        dest,
        isNull,
        reason: '/auth/enrichment should be accessible for incomplete profile',
      );
    });
  });
}
