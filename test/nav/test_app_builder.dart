import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/app/router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/data/core/supabase_provider.dart';
import 'package:khawi_flutter/features/auth/data/auth_repo.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_providers.dart';
import 'package:khawi_flutter/features/profile/data/profile_repo.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/requests/data/requests_repo.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/trips/data/incentive_repo.dart';
import 'package:khawi_flutter/features/trips/domain/area_incentive.dart';
import 'package:khawi_flutter/data/realtime/realtime_service.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/testing/test_overrides.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

class TestRefresh extends ChangeNotifier {
  void tick() => notifyListeners();
}

/// Fake AuthRepo that doesn't hit Supabase.
class _FakeAuthRepo extends Fake implements AuthRepo {
  @override
  Future<void> signOut() async {}
}

/// Fake ProfileRepo that doesn't hit Supabase.
class _FakeProfileRepo extends Fake implements ProfileRepo {
  final Profile _profile;
  _FakeProfileRepo(this._profile);

  @override
  Stream<Profile> watchMyProfile(String uid) => Stream.value(_profile);
}

/// Fake RequestsRepo that doesn't hit Supabase.
class _FakeRequestsRepo extends Fake implements RequestsRepo {
  @override
  Stream<List<TripRequest>> watchSentRequests(String uid) => Stream.value([]);

  @override
  Stream<List<TripRequest>> watchSent(String passengerId) => Stream.value([]);

  @override
  Stream<List<TripRequest>> watchIncomingForDriver(String driverId) =>
      Stream.value([]);
}

/// Fake IncentiveRepo that returns mock test data.
class _FakeIncentiveRepo extends Fake implements IncentiveRepo {
  @override
  Future<List<AreaIncentive>> getIncentives(
    List<String> neighborhoodIds,
  ) async {
    return [
      AreaIncentive(
        areaKey: 'zone_247_466',
        timeBucket: DateTime.now().toIso8601String(),
        multiplier: 1.8,
        reasonTag: 'demand_high',
        computedAt: DateTime.now(),
        meta: {'surge_level': 'high'},
      ),
    ];
  }
}

/// Fake RealtimeService that doesn't hit Supabase.
class _FakeRealtimeService extends Fake implements RealtimeService {
  @override
  Stream<List<TripRequest>> subscribeToBooking(String tripId) =>
      Stream.value([]);

  @override
  Stream<List<TripRequest>> subscribeToDriverQueue(String driverId) =>
      Stream.value([]);

  @override
  Stream<Trip> subscribeToTrip(String tripId) =>
      Stream.error(Exception('Mock'));
}

/// Fake SupabaseClient that doesn't hit real backend.
class _FakeSupabaseClient extends Fake implements SupabaseClient {}

/// Build the REAL app with REAL screens and REAL router.
/// Manually creates a router with injected AsyncValues for precise state control.
Widget buildRealTestApp({
  bool? onboardingDone,
  bool isAuthed = false,
  UserRole? role,
  bool isVerified = true,
  bool isPremium = true,
  bool profileComplete = true,
  bool profileLoading = false,
  String? initialLocation,
  TestRefresh? refresh,
}) {
  final profile = Profile(
    id: 'test_user',
    fullName: profileComplete ? 'Test User' : '',
    role: role ?? UserRole.passenger,
    isPremium: isPremium,
    isVerified: isVerified,
    redeemableXp: 100,
    totalXp: 500,
    avatarUrl: null,
  );

  final authValue = AsyncValue.data(
    isAuthed
        ? Session(
            accessToken: 'test_token',
            tokenType: 'bearer',
            user: User(
              id: 'test_user',
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          )
        : null,
  );

  final profileValue = profileLoading
      ? const AsyncValue<Profile?>.loading()
      : AsyncValue<Profile?>.data(profile);

  final onboardingValue = onboardingDone == null
      ? const AsyncValue<bool>.loading()
      : AsyncValue.data(onboardingDone);

  final router = createRouter(
    auth: authValue,
    profile: profileValue,
    onboardingDone: onboardingValue,
    activeRole: role,
    lastSelectedRole: AsyncValue<UserRole?>.data(role),
    splashLoading: false,
    initialLocation: initialLocation ?? Routes.splash,
    refreshListenable: refresh ?? TestRefresh(),
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'testRootNavigator'),
  );

  return ProviderScope(
    overrides: [
      // Mock user ID for tests
      userIdProvider.overrideWithValue(isAuthed ? 'test_user' : null),
      // Override Supabase provider so repos don't access real backend
      supabaseProvider.overrideWithValue(_FakeSupabaseClient()),
      // Override Supabase-backed providers so shell screens render
      myProfileProvider.overrideWith(
        (ref) => Stream.value(profile),
      ),
      authRepoProvider.overrideWithValue(_FakeAuthRepo()),
      profileRepoProvider.overrideWithValue(_FakeProfileRepo(profile)),
      requestsRepoProvider.overrideWithValue(_FakeRequestsRepo()),
      incentiveRepoProvider.overrideWithValue(_FakeIncentiveRepo()),
      realtimeServiceProvider.overrideWithValue(_FakeRealtimeService()),
      // Mock kids provider for junior hub golden test
      myKidsProvider.overrideWith(
        (ref) => Stream.value(
          [
            const Kid(
              id: 'test_kid_1',
              parentId: 'test_user',
              name: 'Test Kid',
              schoolName: 'Test School',
              avatarUrl: null,
              notes: 'Grade 5',
            ),
          ],
        ),
      ),
      // Mock junior runs provider for junior hub golden test
      myJuniorRunsProvider.overrideWith((ref) => Stream.value([])),
      authSessionProvider.overrideWith(
        (ref) => isAuthed
            ? Stream.value(
                Session(
                  accessToken: 'test_token',
                  tokenType: 'bearer',
                  user: User(
                    id: 'test_user',
                    appMetadata: const {},
                    userMetadata: const {},
                    aud: 'authenticated',
                    createdAt: DateTime.now().toIso8601String(),
                  ),
                ),
              )
            : Stream.value(null),
      ),
      if (role != null)
        activeRoleProvider.overrideWith(
          () => MockActiveRoleNotifier(role),
        ),
      // Override onboarding so the real provider never reads SharedPreferences
      onboardingDoneProvider.overrideWith(
        () => MockOnboardingNotifier(onboardingDone ?? false),
      ),
      // Override last-selected-role so hydration never hits SharedPreferences
      lastSelectedRoleProvider.overrideWith(
        () => MockLastSelectedRoleNotifier(role),
      ),
      // Prevent any stray routerProvider reads from creating a second router
      routerProvider.overrideWithValue(router),
      // Keep other providers overridden
      splashWaitProvider.overrideWith((ref) => Future.value()),
      // Override nowProvider for deterministic golden tests
      nowProvider.overrideWith((ref) => DateTime(2026, 3, 1, 10, 30)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('ar'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        );
      },
    ),
  );
}
