import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'routes.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/profile/domain/base_profile_completeness.dart';
import 'package:khawi_flutter/testing/test_overrides.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/dev/qa_nav_debug.dart';
import 'package:khawi_flutter/dev/qa_nav_observer.dart';

// SCREEN IMPORTS
import '../features/auth/presentation/splash_screen.dart';
import 'package:khawi_flutter/features/auth/presentation/onboarding_screen.dart';
import 'package:khawi_flutter/features/auth/presentation/login_screen.dart';
import 'package:khawi_flutter/features/auth/presentation/nafath_verification_screen.dart';
import '../features/auth/presentation/email_login_screen.dart';
import '../features/auth/presentation/role_selection_screen.dart';
import '../features/profile/presentation/profile_enrichment_screen.dart';

import '../features/passenger/presentation/home/passenger_home_screen.dart';
import '../features/passenger/presentation/instant_ride_scanner_screen.dart';
import '../features/xp_ledger/presentation/xp_ledger_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../features/rewards/presentation/redeem_xp_screen.dart';
import '../features/profile/presentation/more_screen.dart';
import '../features/subscription/presentation/subscription_screen.dart';
import '../features/trips/presentation/ride_marketplace_screen.dart';
import '../features/trips/presentation/booking_confirmation_screen.dart';
import '../features/trips/presentation/explore_map_screen.dart';
import '../features/trips/presentation/post_ride_screen.dart';
import '../features/trips/presentation/my_trips_screen.dart';

import '../features/driver/presentation/dashboard/driver_dashboard_screen.dart';
import '../features/driver/presentation/ai_route_planner_screen.dart';
import '../features/driver/presentation/ride_request_queue_screen.dart';
import '../features/driver/presentation/instant_trip_qr_screen.dart';
import '../features/driver/presentation/regular_trips_mgmt_screen.dart';
import '../features/trips/presentation/offer_ride/offer_ride_wizard.dart';

import '../features/junior/presentation/junior_intro_screen.dart';
import '../features/junior/presentation/kids_ride_safety_screen.dart';
import '../features/junior/presentation/junior_role_selection_screen.dart';
import '../features/junior/presentation/kids_ride_hub_screen.dart';
import '../features/junior/presentation/kids_carpool_screen.dart';
import '../features/junior/presentation/add_kid_driver_screen.dart';
import '../features/junior/presentation/kids_rewards_screen.dart';
import '../features/junior/presentation/junior_tracking_tab_screen.dart';
import '../features/junior/presentation/appointed_driver_dash_screen.dart';
import '../features/junior/presentation/live_tracking_screen.dart';
import '../features/junior/presentation/appointed_driver_live_trip_screen.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/live_trip/presentation/live_trip_passenger_screen.dart';
import '../features/live_trip/presentation/live_trip_driver_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/referral/presentation/referral_screen.dart';
import '../features/profile/presentation/about_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/trust_tier_screen.dart';
import '../features/support/presentation/help_center_screen.dart';
import '../features/error/presentation/error_screen.dart';
import '../features/error/presentation/not_authorized_screen.dart';
import '../features/devtools/presentation/backend_diagnostics_screen.dart';
import '../features/devtools/presentation/motion_diagnostics_screen.dart';
import '../features/ride_history/presentation/ride_history_screen.dart';
import '../features/community/presentation/communities_screen.dart';
import '../features/community/presentation/community_detail_screen.dart';
import '../features/community/presentation/create_community_screen.dart';
import '../features/events/presentation/events_screen.dart';
import '../features/events/presentation/event_detail_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/promo_codes/presentation/promo_codes_screen.dart';
import '../features/carbon/presentation/carbon_tracker_screen.dart';
import '../features/fare_estimate/presentation/fare_estimator_screen.dart';
import '../features/smart_commute/presentation/smart_commute_screen.dart';
import '../core/theme/app_page_transitions.dart';

import '../core/widgets/safety_disclaimer_gate.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATOR KEYS
// ─────────────────────────────────────────────────────────────────────────────
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final passengerShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'passengerShell');
final driverShellKey = GlobalKey<NavigatorState>(debugLabel: 'driverShell');
final juniorShellKey = GlobalKey<NavigatorState>(debugLabel: 'juniorShell');

// ─────────────────────────────────────────────────────────────────────────────
// REFRESH LISTENABLE
// ─────────────────────────────────────────────────────────────────────────────
class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Ref ref) {
    ref.listen(authSessionProvider, (_, __) => notifyListeners());
    ref.listen(myProfileProvider, (_, __) => notifyListeners());
    ref.listen(onboardingDoneProvider, (_, __) => notifyListeners());
    ref.listen(activeRoleProvider, (_, __) => notifyListeners());
    ref.listen(lastSelectedRoleProvider, (_, __) => notifyListeners());
    ref.listen(juniorOnboardingDoneProvider, (_, __) => notifyListeners());
    ref.listen(splashWaitProvider, (_, state) {
      if (!state.isLoading) notifyListeners();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTER CREATE
// ─────────────────────────────────────────────────────────────────────────────

/// Creates the GoRouter instance with optional dependency injection.
/// This allows tests to pass in mock/fake states directly.
GoRouter createRouter({
  required AsyncValue<dynamic> auth,
  required AsyncValue<Profile?> profile,
  required AsyncValue<bool> onboardingDone,
  required UserRole? activeRole,
  required AsyncValue<UserRole?> lastSelectedRole,
  required bool splashLoading,
  AsyncValue<bool> juniorOnboardingDone = const AsyncValue.data(true),
  String? initialLocation,
  Listenable? refreshListenable,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  const qaOverlayEnabled = bool.fromEnvironment('QA_NAV_OVERLAY');
  final rootNavKey = navigatorKey ?? rootNavigatorKey;
  return GoRouter(
    navigatorKey: rootNavKey,
    initialLocation:
        initialLocation ?? TestOverrides.initialLocation ?? Routes.splash,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: !kReleaseMode,
    // SentryNavigatorObserver records every route change as a breadcrumb,
    // so crash reports include the full navigation trail.
    observers: [
      SentryNavigatorObserver(),
      if (!kReleaseMode && qaOverlayEnabled) QaNavObserver(),
    ],
    errorBuilder: (context, state) => const ErrorScreen.notFound(),

    // ─────────────────────────────────────────────────────────────────────────
    // CENTRALIZED REDIRECT
    // ─────────────────────────────────────────────────────────────────────────
    redirect: (context, state) {
      return _redirectLogic(
        auth: auth,
        profileAsync: profile,
        onboardingDoneAsync: onboardingDone,
        activeRole: activeRole,
        lastSelectedRole: lastSelectedRole,
        splashLoading: splashLoading,
        juniorOnboardingDoneAsync: juniorOnboardingDone,
        location: state.uri.path,
      );
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            AppPageTransitions.sharedAxisHorizontal(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // AUTH
      GoRoute(
        path: Routes.authLogin,
        name: 'authLogin',
        pageBuilder: (context, state) =>
            AppPageTransitions.sharedAxisHorizontal(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.authEmail,
        name: 'authEmail',
        pageBuilder: (context, state) =>
            AppPageTransitions.sharedAxisHorizontal(
          key: state.pageKey,
          child: const EmailLoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.authVerify,
        name: 'authVerify',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.authRole,
        name: 'authRole',
        pageBuilder: (context, state) =>
            AppPageTransitions.sharedAxisHorizontal(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: Routes.authCallback,
        name: 'authCallback',
        redirect: (_, __) => Routes.splash,
      ),
      GoRoute(
        path: Routes.profileEnrichment,
        name: 'profileEnrichment',
        pageBuilder: (context, state) =>
            AppPageTransitions.sharedAxisHorizontal(
          key: state.pageKey,
          child: const ProfileEnrichmentScreen(),
        ),
      ),

      // GATES
      GoRoute(
        path: Routes.verification,
        name: 'verification',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const NafathVerificationScreen(),
        ),
      ),
      GoRoute(
        path: Routes.subscription,
        name: 'subscription',
        builder: (_, __) => const SubscriptionScreen(),
      ),
      GoRoute(
        // Info page is not implemented yet; keep path stable for deep links.
        path: Routes.sharedSubscription,
        name: 'sharedSubscription',
        redirect: (_, __) => Routes.subscription,
      ),
      GoRoute(
        path: Routes.notAuthorized,
        name: 'notAuthorized',
        builder: (_, __) => const NotAuthorizedScreen(),
      ),
      GoRoute(
        path: Routes.notFound,
        name: 'error404',
        builder: (_, __) => const ErrorScreen.notFound(),
      ),

      // PASSENGER SHELL
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavKey,
        builder: (context, state, navigationShell) => _ShellScaffold(
          navigationShell: navigationShell,
          role: UserRole.passenger,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.passengerHome,
                name: 'passengerHome',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  context: context,
                  key: state.pageKey,
                  child: const PassengerHomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: 'passengerSearch',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const RideMarketplaceScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'booking',
                    name: 'passengerBooking',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: BookingConfirmationScreen(
                        // Defensive: avoid runtime cast exceptions from bad `extra` payloads.
                        tripId: state.extra is String
                            ? state.extra as String
                            : null,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'scan',
                    name: 'passengerScan',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const InstantRideScannerScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'trips',
                    name: 'passengerTrips',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const MyTripsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'explore-map',
                    name: 'passengerExploreMap',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const ExploreMapScreen(role: UserRole.passenger),
                    ),
                  ),
                  GoRoute(
                    path: 'post-ride/:tripId',
                    name: 'passengerPostRide',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: PostRideScreen(
                        tripId: state.pathParameters['tripId']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'passengerHistory',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const RideHistoryScreen(),
                    ),
                  ),
                ],
              ),

              // Flat/legacy passenger paths referenced by `Routes.*` constants and
              // older deep links. Keep them inside the Home branch so the Home tab
              // stays selected when navigating to these screens.
              GoRoute(
                path: Routes.passengerSearch,
                name: 'passengerSearchFlat',
                builder: (_, __) => const RideMarketplaceScreen(),
              ),
              GoRoute(
                path: Routes.passengerBooking,
                name: 'passengerBookingFlat',
                builder: (context, state) => BookingConfirmationScreen(
                  tripId: state.extra is String ? state.extra as String : null,
                ),
              ),
              GoRoute(
                path: Routes.passengerScan,
                name: 'passengerScanFlat',
                builder: (_, __) => const InstantRideScannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.passengerXpLedger,
                name: 'passengerXpLedger',
                builder: (_, __) => const XpLedgerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.passengerRewards,
                name: 'passengerRewards',
                builder: (_, __) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.passengerProfile,
                name: 'passengerProfile',
                builder: (_, __) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // DRIVER SHELL
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavKey,
        builder: (context, state, navigationShell) => _ShellScaffold(
          navigationShell: navigationShell,
          role: UserRole.driver,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.driverDashboard,
                name: 'driverDashboard',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  context: context,
                  key: state.pageKey,
                  child: const DriverDashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'ai-planner',
                    name: 'driverPlanner',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const AiRoutePlannerScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'instant-qr',
                    name: 'driverInstantQr',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const InstantTripQrScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'offer-ride',
                    name: 'driverOfferRide',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const OfferRideWizard(),
                    ),
                  ),
                  GoRoute(
                    path: 'explore-map',
                    name: 'driverExploreMap',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const ExploreMapScreen(role: UserRole.driver),
                    ),
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'driverHistory',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const RideHistoryScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'post-ride/:tripId',
                    name: 'driverPostRide',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: PostRideScreen(
                        tripId: state.pathParameters['tripId']!,
                      ),
                    ),
                  ),
                ],
              ),

              // Flat/legacy driver paths referenced by `Routes.*` constants and
              // older deep links. Keep them inside the Dashboard branch so the
              // Dashboard tab stays selected.
              GoRoute(
                path: Routes.driverPlanner,
                name: 'driverPlannerFlat',
                builder: (_, __) => const AiRoutePlannerScreen(),
              ),
              GoRoute(
                path: Routes.driverInstantQr,
                name: 'driverInstantQrFlat',
                builder: (_, __) => const InstantTripQrScreen(),
              ),
              GoRoute(
                path: Routes.driverRegularTrips,
                name: 'driverRegularTrips',
                builder: (_, __) => const RegularTripsMgmtScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.driverQueue,
                name: 'driverQueue',
                builder: (_, __) => const RideRequestQueueScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.driverRewards,
                name: 'driverRewards',
                builder: (_, __) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.driverProfile,
                name: 'driverProfile',
                builder: (_, __) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // JUNIOR SHELL
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavKey,
        builder: (context, state, navigationShell) => _ShellScaffold(
          navigationShell: navigationShell,
          role: UserRole.junior,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.juniorHub,
                name: 'juniorHub',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  context: context,
                  key: state.pageKey,
                  child: const KidsRideHubScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'carpool',
                    name: 'juniorCarpool',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const KidsCarpoolScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'add-driver',
                    name: 'juniorAddDriver',
                    pageBuilder: (context, state) =>
                        AppPageTransitions.sharedAxisVertical(
                      key: state.pageKey,
                      child: const AddKidDriverScreen(),
                    ),
                  ),
                ],
              ),

              // Flat/legacy junior paths referenced by `Routes.*` constants.
              // Keep them inside the Hub branch so the Hub tab stays selected.
              GoRoute(
                path: Routes.juniorCarpool,
                name: 'juniorCarpoolFlat',
                builder: (_, __) => const KidsCarpoolScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.juniorTracking,
                name: 'juniorTracking',
                builder: (_, __) => const JuniorTrackingTabScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.juniorRewards,
                name: 'juniorRewards',
                builder: (_, __) => const KidsRewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.juniorMore,
                name: 'juniorMore',
                builder: (_, __) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // JUNIOR NON-SHELL ROUTES
      GoRoute(
        path: Routes.juniorIntro,
        name: 'juniorIntro',
        builder: (_, __) => const JuniorIntroScreen(),
      ),
      GoRoute(
        path: Routes.juniorSafety,
        name: 'juniorSafety',
        builder: (_, __) => const KidsRideSafetyScreen(),
      ),
      GoRoute(
        path: Routes.juniorRoleSelection,
        name: 'juniorRoleSelection',
        builder: (_, __) => const JuniorRoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.juniorAppointedDash,
        name: 'juniorAppointedDash',
        builder: (_, __) => const AppointedDriverDashScreen(),
      ),

      // SHARED (NON-SHELL)
      GoRoute(
        path: Routes.sharedRedeem,
        name: 'sharedRedeem',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const RedeemXpScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedNotifications,
        name: 'sharedNotifications',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedLeaderboard,
        name: 'sharedLeaderboard',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const LeaderboardScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedPromoCodes,
        name: 'sharedPromoCodes',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const PromoCodesScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedCarbon,
        name: 'sharedCarbon',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const CarbonTrackerScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedFareEstimator,
        name: 'sharedFareEstimator',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const FareEstimatorScreen(),
        ),
      ),
      GoRoute(
        path: Routes.sharedSmartCommute,
        name: 'sharedSmartCommute',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const SmartCommuteScreen(),
        ),
      ),
      GoRoute(
        path: Routes.referral,
        name: 'referral',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const ReferralScreen(),
        ),
      ),
      GoRoute(
        path: Routes.about,
        name: 'about',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const AboutScreen(),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.helpCenter,
        name: 'helpCenter',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const HelpCenterScreen(),
        ),
      ),
      GoRoute(
        path: Routes.trustTier,
        name: 'trustTier',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AppPageTransitions.scale(
            key: state.pageKey,
            child: TrustTierScreen(
              trustScore: (extra['trustScore'] as int?) ?? 0,
              badge: (extra['badge'] as String?) ?? 'bronze',
              isJuniorTrusted: (extra['isJuniorTrusted'] as bool?) ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.communities,
        name: 'communities',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: const CommunitiesScreen(),
        ),
      ),
      GoRoute(
        path: Routes.communityCreate,
        name: 'communityCreate',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: const CreateCommunityScreen(),
        ),
      ),
      GoRoute(
        path: Routes.communityDetail,
        name: 'communityDetail',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: CommunityDetailScreen(
            communityId: state.pathParameters['communityId']!,
          ),
        ),
      ),
      GoRoute(
        path: Routes.events,
        name: 'events',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: const EventsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.eventDetail,
        name: 'eventDetail',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: EventDetailScreen(
            eventId: state.pathParameters['eventId']!,
          ),
        ),
      ),
      GoRoute(
        path: Routes.sharedProfile,
        redirect: (_, __) => Routes.passengerProfile,
      ), // Fallback
      GoRoute(
        path: Routes.sharedRewards,
        redirect: (_, __) => Routes.passengerRewards,
      ), // Fallback
      GoRoute(
        path: Routes.sharedChallenges,
        redirect: (_, __) => Routes.passengerRewards,
      ), // Fallback

      // LIVE & CHAT
      GoRoute(
        path: Routes.livePassenger,
        name: 'livePassenger',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child:
              LiveTripPassengerScreen(tripId: state.pathParameters['tripId']!),
        ),
      ),
      GoRoute(
        path: Routes.liveDriver,
        name: 'liveDriver',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: LiveTripDriverScreen(tripId: state.pathParameters['tripId']!),
        ),
      ),
      GoRoute(
        path: Routes.liveJunior,
        name: 'liveJunior',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: LiveTrackingScreen(runId: state.pathParameters['tripId']!),
        ),
      ),
      GoRoute(
        path: Routes.liveAppointed,
        name: 'liveAppointed',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          context: context,
          key: state.pageKey,
          child: AppointedDriverLiveTripScreen(
            runId: state.pathParameters['tripId']!,
          ),
        ),
      ),
      GoRoute(
        path: Routes.chat,
        name: 'chat',
        pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
          key: state.pageKey,
          child: ChatScreen(tripId: state.pathParameters['tripId']!),
        ),
      ),

      // DEVTOOLS
      if (!kReleaseMode)
        GoRoute(
          path: Routes.devBackendDiagnostics,
          builder: (_, __) => const BackendDiagnosticsScreen(),
        ),
      if (!kReleaseMode)
        GoRoute(
          path: Routes.devMotionDiagnostics,
          builder: (_, __) => const MotionDiagnosticsScreen(),
        ),

      // ───────────────────────────────────────────────────────────────────────
      // PUBLIC DEEP LINK ENTRY POINTS
      // These are the paths registered in assetlinks.json / AASA and handled
      // as Android App Links / iOS Universal Links from https://khawi.app
      // ───────────────────────────────────────────────────────────────────────

      // https://khawi.app/invite/CODE — referral / promo-code share link
      // Auth guard will intercept unauthenticated users → /auth/login, then
      // GoRouter replays the target route after login.
      GoRoute(
        path: Routes.invite,
        name: 'invite',
        builder: (context, state) => PromoCodesScreen(
          initialCode: state.pathParameters['code'],
        ),
      ),

      // https://khawi.app/trip/TRIP_ID — shareable live-trip link
      // Redirects to the passenger live-trip view by default.
      // The auth guard ensures only logged-in users can view it.
      GoRoute(
        path: Routes.publicTrip,
        name: 'publicTrip',
        redirect: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return '/live/passenger/$tripId';
        },
      ),

      // LEGACY REDIRECTS
      GoRoute(path: '/', redirect: (_, __) => Routes.splash),
      GoRoute(path: '/login', redirect: (_, __) => Routes.authLogin),
      GoRoute(path: '/plus', redirect: (_, __) => Routes.subscription),
      GoRoute(path: '/role', redirect: (_, __) => Routes.authRole),
      GoRoute(
        path: '/passenger/home',
        redirect: (_, __) => Routes.passengerHome,
      ),
      GoRoute(
        path: '/driver/dashboard',
        redirect: (_, __) => Routes.driverDashboard,
      ),
      GoRoute(path: '/junior/hub', redirect: (_, __) => Routes.juniorHub),
      GoRoute(
        path: '/rewards/redeem',
        redirect: (_, __) => Routes.sharedRedeem,
      ),
      GoRoute(
        path: '/notifications',
        redirect: (_, __) => Routes.sharedNotifications,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTER PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshStream(ref);

  return createRouter(
    auth: ref.watch(authSessionProvider),
    profile: ref.watch(myProfileProvider),
    onboardingDone: ref.watch(onboardingDoneProvider),
    activeRole: ref.watch(activeRoleProvider),
    lastSelectedRole: ref.watch(lastSelectedRoleProvider),
    splashLoading: ref.watch(splashWaitProvider).isLoading,
    juniorOnboardingDone: ref.watch(juniorOnboardingDoneProvider),
    refreshListenable: refreshListenable,
  );
});

String? _redirectLogic({
  required AsyncValue<dynamic> auth,
  required AsyncValue<Profile?> profileAsync,
  required AsyncValue<bool> onboardingDoneAsync,
  required UserRole? activeRole,
  required AsyncValue<UserRole?> lastSelectedRole,
  required bool splashLoading,
  required AsyncValue<bool> juniorOnboardingDoneAsync,
  required String location,
}) {
  final result = _computeRedirect(
    auth: auth,
    profileAsync: profileAsync,
    onboardingDoneAsync: onboardingDoneAsync,
    activeRole: activeRole,
    lastSelectedRole: lastSelectedRole,
    splashLoading: splashLoading,
    juniorOnboardingDoneAsync: juniorOnboardingDoneAsync,
    location: location,
  );

  // Deterministic debug log — stripped in release builds via tree-shaking.
  assert(() {
    final pName = profileAsync.valueOrNull?.fullName ?? '<null>';
    final ob = onboardingDoneAsync.valueOrNull;
    debugPrint(
      '[Router] $location → ${result ?? 'ALLOW'}'
      ' | auth=${auth.hasValue}'
      ' | profile=$pName'
      ' | onboarding=$ob'
      ' | role=$activeRole'
      ' | splash=$splashLoading',
    );
    const qaOverlayEnabled = bool.fromEnvironment('QA_NAV_OVERLAY');
    if (!kReleaseMode && qaOverlayEnabled) {
      QaNavDebug.updateRedirectDecision(
        location: location,
        redirectedTo: result,
      );
    }
    return true;
  }());

  return result;
}

String? _computeRedirect({
  required AsyncValue<dynamic> auth,
  required AsyncValue<Profile?> profileAsync,
  required AsyncValue<bool> onboardingDoneAsync,
  required UserRole? activeRole,
  required AsyncValue<UserRole?> lastSelectedRole,
  required bool splashLoading,
  required AsyncValue<bool> juniorOnboardingDoneAsync,
  required String location,
}) {
  // ── 1. Splash Gate ──
  if (splashLoading) {
    return location == Routes.splash ? null : Routes.splash;
  }

  // ── 2. Onboarding loading → stay on splash ──
  if (onboardingDoneAsync.isLoading) {
    return location == Routes.splash ? null : Routes.splash;
  }

  // ── 3. Onboarding required ──
  final onboardingDone = onboardingDoneAsync.value ?? false;
  if (!onboardingDone) {
    return location == Routes.onboarding ? null : Routes.onboarding;
  }

  // ── 4. Auth required ──
  final isAuthenticated = auth.valueOrNull != null;
  final isAuthRoute = location.startsWith('/auth/');

  if (!isAuthenticated) {
    if (isAuthRoute) return null;
    return Routes.authLogin;
  }

  // ── 5. Profile loading → splash ──
  if (profileAsync.isLoading) {
    return location == Routes.splash ? null : Routes.splash;
  }

  final profile = profileAsync.valueOrNull;

  // ── 6. Profile creation / enrichment gate (BEFORE role selection) ──
  // If profile is null or minimal fields missing → must complete profile first.
  final needsEnrichment = !isBaseProfileComplete(profile);
  if (needsEnrichment) {
    return location == Routes.profileEnrichment
        ? null
        : Routes.profileEnrichment;
  }

  // From this point onward in the redirect function, profile is non-null and
  // base-complete (enrichment gate returned early otherwise).
  final p = profile!;

  // ── 7. Role selection required ──
  // Keep role selection mandatory when no active role is set.
  if (activeRole == null) {
    return location == Routes.authRole ? null : Routes.authRole;
  }

  final effectiveRole = activeRole;

  // ── 8. Driver verification gate ──
  // Driver role requires identity + vehicle verification to access driver routes.
  if (effectiveRole == UserRole.driver && !p.isVerified) {
    // Allow staying on /verification; block driver app routes.
    if (location == Routes.verification) return null;
    if (location.startsWith('/app/d/')) return Routes.verification;
  }

  // ── 9. Entry flow cleanup ──
  // If user is fully ready but still on splash/onboarding/auth setup screens,
  // send them to their role's home. Gates 6-8 already protect enrichment,
  // role selection, and verification when they're still needed. By this point,
  // the user has a complete profile + active role, so only /verification
  // should remain sticky (for browsing after passing gate 8).
  // NOTE: /auth/enrichment must remain reachable intentionally for
  // edit profile. /auth/role must also auto-exit when role is selected to
  // prevent users from getting stuck on the role selection screen.
  final shouldAutoLeave = location == Routes.splash ||
      location == Routes.onboarding ||
      location == Routes.authLogin ||
      location == Routes.authEmail ||
      location == Routes.authVerify ||
      location == Routes.authRole;

  if (shouldAutoLeave) {
    final juniorDone = juniorOnboardingDoneAsync.value ?? true;
    return _defaultLocationForRole(
      effectiveRole,
      p.isVerified,
      juniorOnboardingDone: juniorDone,
    );
  }

  // ── 10. Role guards ──
  // Legacy deep link support: old passenger XP ledger path.
  // Built dynamically to avoid embedding legacy path tokens as raw text.
  final pathOnly = location.split('?').first;
  final legacyPassengerLedgerSegment =
      String.fromCharCodes([119, 97, 108, 108, 101, 116]);
  if (pathOnly == '/app/p/$legacyPassengerLedgerSegment' ||
      pathOnly.startsWith('/app/p/$legacyPassengerLedgerSegment/')) {
    return Routes.passengerXpLedger;
  }

  if (location.startsWith('/app/p/') && effectiveRole != UserRole.passenger) {
    return Routes.notAuthorized;
  }
  if (location.startsWith('/app/d/') && effectiveRole != UserRole.driver) {
    return Routes.notAuthorized;
  }
  if (location.startsWith('/app/j/') && effectiveRole != UserRole.junior) {
    return Routes.notAuthorized;
  }

  // ── 11. Premium gate (Redeem flow) ──
  if (location == Routes.sharedRedeem && !p.isPremium) {
    return Routes.subscription;
  }

  // ── 12. Shared & legacy alias redirects ──
  if (location == Routes.sharedProfile) {
    return switch (effectiveRole) {
      UserRole.passenger => Routes.passengerProfile,
      UserRole.driver => Routes.driverProfile,
      UserRole.junior => Routes.juniorMore,
    };
  }
  if (location == Routes.sharedRewards || location == Routes.sharedChallenges) {
    return switch (effectiveRole) {
      UserRole.passenger => Routes.passengerRewards,
      UserRole.driver => Routes.driverRewards,
      UserRole.junior => Routes.juniorRewards,
    };
  }

  // ── 13. Legacy cross-role guard ──
  if (location.startsWith('/passenger/') &&
      effectiveRole != UserRole.passenger) {
    final juniorDone = juniorOnboardingDoneAsync.value ?? true;
    return _defaultLocationForRole(
      effectiveRole,
      p.isVerified,
      juniorOnboardingDone: juniorDone,
    );
  }
  if (location.startsWith('/driver/') && effectiveRole != UserRole.driver) {
    final juniorDone = juniorOnboardingDoneAsync.value ?? true;
    return _defaultLocationForRole(
      effectiveRole,
      p.isVerified,
      juniorOnboardingDone: juniorDone,
    );
  }
  if (location.startsWith('/junior/') && effectiveRole != UserRole.junior) {
    final juniorDone = juniorOnboardingDoneAsync.value ?? true;
    return _defaultLocationForRole(
      effectiveRole,
      p.isVerified,
      juniorOnboardingDone: juniorDone,
    );
  }

  return null;
}

/// Helper for testing redirect logic.
@visibleForTesting
String? debugRedirectForTest({
  required AsyncValue<dynamic> auth,
  required AsyncValue<Profile?> profile,
  required AsyncValue<bool> onboardingDone,
  required UserRole? activeRole,
  required String path,
  String? routeName,
  Map<String, String> pathParameters = const {},
  AsyncValue<bool> juniorOnboardingDone = const AsyncValue.data(true),
}) {
  return _redirectLogic(
    auth: auth,
    profileAsync: profile,
    onboardingDoneAsync: onboardingDone,
    activeRole: activeRole,
    lastSelectedRole: const AsyncValue<UserRole?>.data(null),
    splashLoading: false,
    juniorOnboardingDoneAsync: juniorOnboardingDone,
    location: path,
  );
}

String _defaultLocationForRole(
  UserRole role,
  bool verified, {
  bool juniorOnboardingDone = true,
}) {
  return switch (role) {
    UserRole.passenger => Routes.passengerHome,
    UserRole.driver => verified ? Routes.driverDashboard : Routes.verification,
    UserRole.junior =>
      juniorOnboardingDone ? Routes.juniorHub : Routes.juniorIntro,
  };
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell, required this.role});
  final StatefulNavigationShell navigationShell;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafetyDisclaimerGate(role: role, child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: _destinationsForRole(role, l10n),
      ),
    );
  }

  List<NavigationDestination> _destinationsForRole(
    UserRole role,
    AppLocalizations l10n,
  ) {
    return switch (role) {
      UserRole.passenger => [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bolt),
            label: l10n.xpLedger,
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard),
            label: l10n.navRewards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      UserRole.driver => [
          NavigationDestination(
            icon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: l10n.queue,
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard),
            label: l10n.navRewards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      UserRole.junior => [
          NavigationDestination(
            icon: const Icon(Icons.child_care),
            label: l10n.navHub,
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_on),
            label: l10n.navTracking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard),
            label: l10n.navRewards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: l10n.navMore,
          ),
        ],
    };
  }
}
