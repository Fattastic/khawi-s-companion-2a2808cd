// ─────────────────────────────────────────────────────────────────────────────
// DELIVERABLE 2: ROUTE GRAPH EXTRACTION TOOL
// Run: flutter test test/routing_debugger/route_graph_extractor_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Canonical Route Table (DELIVERABLE 1 – machine-readable)
// ─────────────────────────────────────────────────────────────────────────────
/// Every screen MUST have exactly one canonical path.  Aliases are redirect-only.
const Map<String, String?> canonicalRoutes = {
  // ENTRY & AUTH
  '/splash': 'splash',
  '/onboarding': 'onboarding',
  '/auth/login': 'authLogin',
  '/auth/email': 'authEmail',
  '/auth/verify': 'authVerify',
  '/auth/role': 'authRole',
  '/auth/callback': 'authCallback', // redirect-only
  '/auth/enrichment': 'profileEnrichment',

  // GATES
  '/verification': 'verification',
  '/subscription': 'subscription',
  '/not-authorized': 'notAuthorized',
  '/404': 'error404',

  // PASSENGER SHELL
  '/app/p/home': 'passengerHome',
  '/app/p/home/search': 'passengerSearch',
  '/app/p/home/booking': 'passengerBooking',
  '/app/p/home/scan': 'passengerScan',
  '/app/p/home/explore-map': 'passengerExploreMap',
  '/app/p/home/post-ride/:tripId': 'passengerPostRide',
  '/app/p/xp-ledger': 'passengerXpLedger',
  '/app/p/rewards': 'passengerRewards',
  '/app/p/profile': 'passengerProfile',

  // DRIVER SHELL
  '/app/d/dashboard': 'driverDashboard',
  '/app/d/dashboard/ai-planner': 'driverPlanner',
  '/app/d/dashboard/instant-qr': 'driverInstantQr',
  '/app/d/dashboard/offer-ride': 'driverOfferRide',
  '/app/d/dashboard/explore-map': 'driverExploreMap',
  '/app/d/queue': 'driverQueue',
  '/app/d/rewards': 'driverRewards',
  '/app/d/profile': 'driverProfile',

  // JUNIOR SHELL
  '/app/j/hub': 'juniorHub',
  '/app/j/hub/carpool': 'juniorCarpool',
  '/app/j/hub/add-driver': 'juniorAddDriver',
  '/app/j/tracking': 'juniorTracking',
  '/app/j/rewards': 'juniorRewards',
  '/app/j/more': 'juniorMore',

  // JUNIOR NON-SHELL
  '/app/j/splash': 'juniorIntro',
  '/app/j/safety': 'juniorSafety',
  '/app/j/role': 'juniorRoleSelection',
  '/app/j/appointed/dashboard': 'juniorAppointedDash',

  // SHARED (NON-SHELL)
  '/shared/redeem': 'sharedRedeem',
  '/shared/notifications': 'sharedNotifications',
  '/referral': 'referral',

  // SHARED REDIRECT-ONLY (redirect via _redirectLogic, route-level redirect)
  '/shared/profile': null, // redirect-only
  '/shared/rewards': null, // redirect-only
  '/shared/challenges': null, // redirect-only

  // LIVE & CHAT
  '/live/passenger/:tripId': 'livePassenger',
  '/live/driver/:tripId': 'liveDriver',
  '/live/junior/:tripId': 'liveJunior',
  '/live/appointed/:tripId': 'liveAppointed',
  '/chat/:tripId': 'chat',
};

/// Legacy aliases that MUST redirect-only (no builder).
const Map<String, String> legacyRedirects = {
  '/': '/splash',
  '/login': '/auth/login',
  '/plus': '/subscription',
  '/role': '/auth/role',
  '/passenger/home': '/app/p/home',
  '/driver/dashboard': '/app/d/dashboard',
  '/junior/hub': '/app/j/hub',
  '/rewards/redeem': '/shared/redeem',
  '/notifications': '/shared/notifications',
};

// ─────────────────────────────────────────────────────────────────────────────
// Route Tree Walker
// ─────────────────────────────────────────────────────────────────────────────
class _RouteNode {
  final String fullPath;
  final String? name;
  final bool hasBuilder;
  final bool isRedirectOnly;
  final String? redirectTarget;
  final String shellRole; // 'none', 'passenger', 'driver', 'junior'
  final int depth;

  _RouteNode({
    required this.fullPath,
    this.name,
    required this.hasBuilder,
    required this.isRedirectOnly,
    this.redirectTarget,
    this.shellRole = 'none',
    this.depth = 0,
  });

  @override
  String toString() {
    final tag = isRedirectOnly
        ? '→ REDIRECT'
        : hasBuilder
            ? 'BUILDER'
            : 'EMPTY';
    final n = name != null ? ' (name: $name)' : '';
    final s = shellRole != 'none' ? ' [shell: $shellRole]' : '';
    return '${'  ' * depth}$fullPath$n  [$tag]$s';
  }
}

List<_RouteNode> _walkRoutes(
  List<RouteBase> routes, {
  String parentPath = '',
  String shellRole = 'none',
  int depth = 0,
}) {
  final nodes = <_RouteNode>[];
  for (final route in routes) {
    if (route is GoRoute) {
      final path =
          route.path.startsWith('/') ? route.path : '$parentPath/${route.path}';
      final isRedirect = route.redirect != null;
      final hasBuilder = route.builder != null || route.pageBuilder != null;
      nodes.add(
        _RouteNode(
          fullPath: path,
          name: route.name,
          hasBuilder: hasBuilder,
          isRedirectOnly: isRedirect && !hasBuilder,
          redirectTarget: isRedirect ? '(dynamic)' : null,
          shellRole: shellRole,
          depth: depth,
        ),
      );
      if (route.routes.isNotEmpty) {
        nodes.addAll(
          _walkRoutes(
            route.routes,
            parentPath: path,
            shellRole: shellRole,
            depth: depth + 1,
          ),
        );
      }
    } else if (route is StatefulShellRoute) {
      // Infer shell role from first branch path prefix
      String inferredRole = shellRole;
      final branches = route.branches;
      if (branches.isNotEmpty) {
        final first = branches.first.routes.first;
        if (first is GoRoute) {
          if (first.path.startsWith('/app/p')) {
            inferredRole = 'passenger';
          } else if (first.path.startsWith('/app/d')) {
            inferredRole = 'driver';
          } else if (first.path.startsWith('/app/j')) {
            inferredRole = 'junior';
          }
        }
      }
      for (final branch in branches) {
        nodes.addAll(
          _walkRoutes(
            branch.routes,
            parentPath: parentPath,
            shellRole: inferredRole,
            depth: depth,
          ),
        );
      }
    } else if (route is ShellRoute) {
      nodes.addAll(
        _walkRoutes(
          route.routes,
          parentPath: parentPath,
          shellRole: shellRole,
          depth: depth,
        ),
      );
    }
  }
  return nodes;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
GoRouter _makeRouter() {
  return createRouter(
    auth: const AsyncValue.data('mock_session'),
    profile: const AsyncValue.data(
      Profile(
        id: 'test',
        fullName: 'Test User',
        role: UserRole.passenger,
        isPremium: true,
        isVerified: true,
        totalXp: 0,
        redeemableXp: 0,
      ),
    ),
    onboardingDone: const AsyncValue.data(true),
    activeRole: UserRole.passenger,
    lastSelectedRole: const AsyncValue<UserRole?>.data(UserRole.passenger),
    splashLoading: false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Route Graph Extraction (Deliverable 2)', () {
    late GoRouter router;
    late List<_RouteNode> nodes;

    setUpAll(() {
      router = _makeRouter();
      nodes = _walkRoutes(router.configuration.routes);
    });

    test('PRINT: Full Route Tree', () {
      debugPrint(
          '\n╔══════════════════════════════════════════════════════════╗',);
      debugPrint('║            KHAWI ROUTE TREE (extracted)                 ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝',);
      for (final n in nodes) {
        debugPrint(n.toString());
      }
      debugPrint('Total routes: ${nodes.length}');
    });

    test('NO duplicate full paths', () {
      final paths = nodes.map((n) => n.fullPath).toList();
      final seen = <String>{};
      final dupes = <String>[];
      for (final p in paths) {
        if (!seen.add(p)) dupes.add(p);
      }
      if (dupes.isNotEmpty) {
        debugPrint('⚠ DUPLICATE PATHS: $dupes');
      }
      expect(dupes, isEmpty, reason: 'Duplicate full paths found: $dupes');
    });

    test('NO duplicate route names', () {
      final names =
          nodes.where((n) => n.name != null).map((n) => n.name!).toList();
      final seen = <String>{};
      final dupes = <String>[];
      for (final n in names) {
        if (!seen.add(n)) dupes.add(n);
      }
      if (dupes.isNotEmpty) {
        debugPrint('⚠ DUPLICATE NAMES: $dupes');
      }
      expect(dupes, isEmpty, reason: 'Duplicate route names found: $dupes');
    });

    test('Every canonical route is in the graph', () {
      final graphPaths = nodes.map((n) => n.fullPath).toSet();
      final missing = <String>[];
      for (final entry in canonicalRoutes.entries) {
        if (!graphPaths.contains(entry.key)) {
          missing.add(entry.key);
        }
      }
      if (missing.isNotEmpty) {
        debugPrint('⚠ MISSING CANONICAL ROUTES: $missing');
      }
      // /dev/backend-diagnostics may be excluded in release, filter it
      missing.removeWhere((p) => p.startsWith('/dev/'));
      expect(
        missing,
        isEmpty,
        reason: 'Canonical routes missing from graph: $missing',
      );
    });

    test('Every legacy alias is redirect-only (no builder)', () {
      final violations = <String>[];
      for (final legacyPath in legacyRedirects.keys) {
        final node = nodes.where((n) => n.fullPath == legacyPath).firstOrNull;
        if (node == null) {
          violations.add('$legacyPath NOT FOUND in graph');
          continue;
        }
        if (node.hasBuilder && !node.isRedirectOnly) {
          violations.add('$legacyPath has a builder (should be redirect-only)');
        }
      }
      if (violations.isNotEmpty) {
        debugPrint('⚠ LEGACY ALIAS VIOLATIONS: $violations');
      }
      expect(
        violations,
        isEmpty,
        reason: 'Legacy aliases with builders: $violations',
      );
    });

    test('Redirect-only canonical routes have no builder', () {
      final violations = <String>[];
      for (final entry in canonicalRoutes.entries) {
        if (entry.value == null) {
          // Should be redirect-only
          final node = nodes.where((n) => n.fullPath == entry.key).firstOrNull;
          if (node != null && node.hasBuilder && !node.isRedirectOnly) {
            violations
                .add('${entry.key} should be redirect-only but has builder');
          }
        }
      }
      if (violations.isNotEmpty) {
        debugPrint('⚠ REDIRECT-ONLY VIOLATIONS: $violations');
      }
      expect(violations, isEmpty);
    });

    test('Shell routes have correct shell role assignment', () {
      final passengerNodes =
          nodes.where((n) => n.fullPath.startsWith('/app/p/')).toList();
      final driverNodes =
          nodes.where((n) => n.fullPath.startsWith('/app/d/')).toList();
      final juniorNodes =
          nodes.where((n) => n.fullPath.startsWith('/app/j/')).toList();

      for (final n in passengerNodes) {
        expect(
          n.shellRole,
          'passenger',
          reason: '${n.fullPath} should be in passenger shell',
        );
      }
      for (final n in driverNodes) {
        expect(
          n.shellRole,
          'driver',
          reason: '${n.fullPath} should be in driver shell',
        );
      }
      // Junior shell routes (not juniorIntro/juniorSafety/juniorRoleSelection which are non-shell)
      for (final n in juniorNodes) {
        if (n.fullPath == Routes.juniorIntro ||
            n.fullPath == Routes.juniorSafety ||
            n.fullPath == Routes.juniorRoleSelection ||
            n.fullPath == Routes.juniorAppointedDash) {
          // Non-shell routes
          continue;
        }
        expect(
          n.shellRole,
          'junior',
          reason: '${n.fullPath} should be in junior shell',
        );
      }
    });

    test('PRINT: Canonicalization Report', () {
      debugPrint(
          '\n╔══════════════════════════════════════════════════════════╗',);
      debugPrint('║         CANONICALIZATION REPORT                         ║');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝',);

      // Check Routes.dart constants match actual router paths
      final routeConstants = {
        'passengerHome': Routes.passengerHome,
        'passengerSearch': Routes.passengerSearchAlias,
        'passengerScan': Routes.passengerScan,
        'passengerXpLedger': Routes.passengerXpLedger,
        'passengerRewards': Routes.passengerRewards,
        'passengerProfile': Routes.passengerProfile,
        'driverDashboard': Routes.driverDashboard,
        'driverQueue': Routes.driverQueue,
        'driverRewards': Routes.driverRewards,
        'driverProfile': Routes.driverProfile,
        'juniorHub': Routes.juniorHub,
        'juniorTracking': Routes.juniorTracking,
        'juniorRewards': Routes.juniorRewards,
        'juniorMore': Routes.juniorMore,
      };

      final graphPaths = nodes.map((n) => n.fullPath).toSet();
      for (final entry in routeConstants.entries) {
        final inGraph = graphPaths.contains(entry.value);
        debugPrint(
            '  ${entry.key}: ${entry.value} ${inGraph ? '✓' : '✗ NOT FOUND'}',);
      }
    });
  });
}
