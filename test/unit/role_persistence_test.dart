// ─────────────────────────────────────────────────────────────────────────────
// Role Persistence & Atomicity Tests
// Run: flutter test test/unit/role_persistence_test.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Verifies:
// 1. activeRoleProvider is ALWAYS null on cold start (forces role-selection).
// 2. lastSelectedRoleProvider still reads/writes SharedPreferences correctly.
// 3. setRole() updates activeRoleProvider in-session AND persists to prefs.
// 4. clear() resets activeRoleProvider to null AND removes the persisted value.
// 5. Redirect logic: null activeRole → /auth/role; set role → correct home.
// 6. Web-refresh: lastSelectedRoleProvider retains persisted value;
//    activeRoleProvider is null (user must re-select role each session).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/app_settings.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

/// Multi-hop redirect resolver (same as state_matrix_test).
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
    final next = debugRedirectForTest(
      auth: auth ?? const AsyncValue.data('session'),
      profile: profile ?? AsyncValue.data(_p()),
      onboardingDone: onboardingDone ?? const AsyncValue.data(true),
      activeRole: activeRole,
      path: current,
    );
    if (next == null || next == current) return current;
    current = next;
  }
  return 'LOOP($current)';
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('Role Persistence – SharedPreferences contract', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('P1: lastSelectedRoleProvider reads null when prefs are empty',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final role = await container.read(lastSelectedRoleProvider.future);
      expect(role, isNull);
    });

    test('P2: lastSelectedRoleProvider reads persisted role from prefs',
        () async {
      SharedPreferences.setMockInitialValues({'khawi_last_role': 'driver'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final role = await container.read(lastSelectedRoleProvider.future);
      expect(role, UserRole.driver);
    });

    test('P3: setLastRole persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(lastSelectedRoleProvider.notifier)
          .setLastRole(UserRole.junior);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('khawi_last_role'), 'junior');
    });

    test(
        'P4: activeRoleProvider is null on cold start even when role is persisted '
        '(by design: user must select role each session)', () async {
      SharedPreferences.setMockInitialValues({'khawi_last_role': 'passenger'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // lastSelectedRoleProvider still reads from SharedPreferences.
      final persisted = await container.read(lastSelectedRoleProvider.future);
      expect(persisted, UserRole.passenger); // value IS persisted…

      // …but activeRoleProvider intentionally ignores it on cold start.
      // This forces role-selection on every app open.
      final activeRole = container.read(activeRoleProvider);
      expect(activeRole, isNull);
    });

    test('P5: activeRoleProvider is null when no persisted role exists',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Let the async provider load.
      await container.read(lastSelectedRoleProvider.future);

      final activeRole = container.read(activeRoleProvider);
      expect(activeRole, isNull);
    });

    test('P6: setRole persists and updates activeRoleProvider synchronously',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial load.
      await container.read(lastSelectedRoleProvider.future);

      // Set role.
      container.read(activeRoleProvider.notifier).setRole(UserRole.driver);

      // Synchronous read should return the new role immediately.
      expect(container.read(activeRoleProvider), UserRole.driver);

      // Give the async persistence time to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('khawi_last_role'), 'driver');
    });

    test('P7: clear() removes persisted role and resets to null', () async {
      SharedPreferences.setMockInitialValues({'khawi_last_role': 'driver'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(lastSelectedRoleProvider.future);
      // activeRoleProvider always starts null (cold-start design).
      expect(container.read(activeRoleProvider), isNull);

      // Set a role in-session then clear it.
      container.read(activeRoleProvider.notifier).setRole(UserRole.driver);
      expect(container.read(activeRoleProvider), UserRole.driver);

      container.read(activeRoleProvider.notifier).clear();
      expect(container.read(activeRoleProvider), isNull);

      // Give the async removal time to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('khawi_last_role'), isNull);
    });
  });

  group('Role Persistence – Redirect behavior', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('R-P1: persisted role skips /auth/role gate', () {
      final dest = _resolve(
        Routes.splash,
        activeRole: UserRole.passenger,
        profile: AsyncValue.data(_p(fullName: 'Ahmed')),
      );
      expect(dest, Routes.passengerHome);
    });

    test('R-P2: null persisted role → /auth/role', () {
      final dest = _resolve(
        Routes.splash,
        activeRole: null,
        profile: AsyncValue.data(_p(fullName: 'Ahmed')),
      );
      expect(dest, Routes.authRole);
    });

    test('R-P3: persisted driver role + verified → driver dashboard', () {
      final dest = _resolve(
        Routes.splash,
        activeRole: UserRole.driver,
        profile: AsyncValue.data(_p(fullName: 'Ahmed', isVerified: true)),
      );
      expect(dest, Routes.driverDashboard);
    });

    test('R-P4: persisted driver role + unverified → /verification', () {
      final dest = _resolve(
        '/app/d/dashboard',
        activeRole: UserRole.driver,
        profile: AsyncValue.data(_p(fullName: 'Ahmed', isVerified: false)),
      );
      expect(dest, Routes.verification);
    });

    test('R-P5: persisted junior role → junior hub', () {
      final dest = _resolve(
        Routes.splash,
        activeRole: UserRole.junior,
        profile: AsyncValue.data(_p(fullName: 'Ahmed')),
      );
      expect(dest, Routes.juniorHub);
    });
  });

  group('Web Refresh Simulation', () {
    // Simulates a web page refresh by creating a fresh ProviderContainer
    // with the same SharedPreferences state.

    test(
        'W1: setRole persists to SharedPreferences; on web refresh the '
        'persisted value is readable via lastSelectedRoleProvider '
        '(activeRoleProvider is null by design – role re-selection required)',
        () async {
      // Session 1: User selects a role.
      SharedPreferences.setMockInitialValues({});
      final container1 = ProviderContainer();
      await container1.read(lastSelectedRoleProvider.future);
      container1.read(activeRoleProvider.notifier).setRole(UserRole.passenger);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      container1.dispose();

      // Session 2: Fresh container (simulate web refresh).
      // SharedPreferences retains the value from session 1.
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // The persisted value is still in SharedPreferences.
      final persisted = await container2.read(lastSelectedRoleProvider.future);
      expect(persisted, UserRole.passenger);

      // But activeRoleProvider is null — user must re-select role each session.
      expect(container2.read(activeRoleProvider), isNull);
    });

    test('W2: role change in session 2 persists correctly', () async {
      SharedPreferences.setMockInitialValues({'khawi_last_role': 'passenger'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(lastSelectedRoleProvider.future);

      // Change role.
      container.read(activeRoleProvider.notifier).setRole(UserRole.driver);
      expect(container.read(activeRoleProvider), UserRole.driver);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('khawi_last_role'), 'driver');
    });

    test(
        'W3: after simulated refresh, redirect goes to /auth/role because '
        'activeRoleProvider is null (user must re-select role)', () async {
      SharedPreferences.setMockInitialValues({'khawi_last_role': 'junior'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(lastSelectedRoleProvider.future);

      // activeRoleProvider is null on cold start – by design.
      final role = container.read(activeRoleProvider);
      expect(role, isNull);

      final dest = _resolve(
        Routes.splash,
        activeRole: role,
        profile: AsyncValue.data(_p(fullName: 'Ahmed')),
      );
      // With no active role the router sends user to role selection.
      expect(dest, Routes.authRole);

      // Verify that once the user selects "junior" in-session, they go to hub.
      final destAfterSelect = _resolve(
        Routes.splash,
        activeRole: UserRole.junior,
        profile: AsyncValue.data(_p(fullName: 'Ahmed')),
      );
      expect(destAfterSelect, Routes.juniorHub);
    });
  });
}
