import 'package:khawi_flutter/features/profile/domain/profile.dart';

import 'routes.dart';

enum ScreenId {
  // Entry
  splash,
  onboarding,
  login,

  roleSelection,

  // Passenger
  passengerHome,
  rideSearch,
  bookingConfirmation,
  passengerLiveTrip,
  postRideXpAward,
  instantRideScanner,

  // Driver
  driverDashboard,
  rideRequestQueue,
  driverLiveTrip,
  aiRoutePlanner,
  regularTripsMgmt,
  instantTripQr,

  // Junior
  juniorIntro,
  safetyLegal,
  juniorRoleSelection,
  juniorHub,
  childTrackingView,
  kidsRewardsShop,
  appointedDriverDash,
  appointedDriverLive,

  // Shared
  userProfile,
  khawiSubscription,
  notificationSettings,
  rewardsShop,
  redeemXp,
  weeklyChallenges,
}

class RouteMeta {
  final String path;
  final ScreenId screenId;
  final String screenName;
  final Set<UserRole?> allowedRoles;

  const RouteMeta({
    required this.path,
    required this.screenId,
    required this.screenName,
    required this.allowedRoles,
  });
}

abstract final class RouteMap {
  static const all = <RouteMeta>[
    // Entry (no role yet)
    RouteMeta(
      path: Routes.splash,
      screenId: ScreenId.splash,
      screenName: 'Splash Screen',
      allowedRoles: {null},
    ),
    RouteMeta(
      path: Routes.onboarding,
      screenId: ScreenId.onboarding,
      screenName: 'Onboarding Carousel',
      allowedRoles: {null},
    ),
    RouteMeta(
      path: Routes.authLogin,
      screenId: ScreenId.login,
      screenName: 'Login Screen',
      allowedRoles: {null},
    ),

    RouteMeta(
      path: Routes.authRole,
      screenId: ScreenId.roleSelection,
      screenName: 'Role Selection Fork',
      allowedRoles: {null},
    ),

    // Passenger
    RouteMeta(
      path: Routes.passengerHome,
      screenId: ScreenId.passengerHome,
      screenName: 'Passenger Home',
      allowedRoles: {UserRole.passenger},
    ),
    RouteMeta(
      path: Routes.passengerSearch,
      screenId: ScreenId.rideSearch,
      screenName: 'Ride Search',
      allowedRoles: {UserRole.passenger},
    ),
    RouteMeta(
      path: Routes.passengerBooking,
      screenId: ScreenId.bookingConfirmation,
      screenName: 'Booking Confirmation',
      allowedRoles: {UserRole.passenger},
    ),
    RouteMeta(
      path: Routes.livePassenger,
      screenId: ScreenId.passengerLiveTrip,
      screenName: 'Passenger Live Trip',
      allowedRoles: {UserRole.passenger},
    ),
    RouteMeta(
      path: Routes.passengerPostRide,
      screenId: ScreenId.postRideXpAward,
      screenName: 'Post-Ride & XP Award',
      allowedRoles: {UserRole.passenger},
    ),
    RouteMeta(
      path: Routes.passengerScan,
      screenId: ScreenId.instantRideScanner,
      screenName: 'Instant Ride Scanner',
      allowedRoles: {UserRole.passenger},
    ),

    // Driver
    RouteMeta(
      path: Routes.driverDashboard,
      screenId: ScreenId.driverDashboard,
      screenName: 'Driver Dashboard',
      allowedRoles: {UserRole.driver},
    ),
    RouteMeta(
      path: Routes.driverPlanner,
      screenId: ScreenId.aiRoutePlanner,
      screenName: 'AI Route Planner',
      allowedRoles: {UserRole.driver},
    ),
    RouteMeta(
      path: Routes.driverQueue,
      screenId: ScreenId.rideRequestQueue,
      screenName: 'Ride Request Queue',
      allowedRoles: {UserRole.driver},
    ),
    RouteMeta(
      path: Routes.liveDriver,
      screenId: ScreenId.driverLiveTrip,
      screenName: 'Driver Live Trip',
      allowedRoles: {UserRole.driver},
    ),
    RouteMeta(
      path: Routes.driverRegularTrips,
      screenId: ScreenId.regularTripsMgmt,
      screenName: 'Regular Trips Mgmt',
      allowedRoles: {UserRole.driver},
    ),
    RouteMeta(
      path: Routes.driverInstantQr,
      screenId: ScreenId.instantTripQr,
      screenName: 'Instant Trip QR',
      allowedRoles: {UserRole.driver},
    ),

    // Junior
    RouteMeta(
      path: Routes.juniorIntro,
      screenId: ScreenId.juniorIntro,
      screenName: 'Junior Intro',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorSafety,
      screenId: ScreenId.safetyLegal,
      screenName: 'Safety & Legal',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorRoleSelection,
      screenId: ScreenId.juniorRoleSelection,
      screenName: 'Junior Role Selection',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorHub,
      screenId: ScreenId.juniorHub,
      screenName: 'Junior Hub',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorTracking,
      screenId: ScreenId.childTrackingView,
      screenName: 'Child Tracking View',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorRewards,
      screenId: ScreenId.kidsRewardsShop,
      screenName: 'Kids Rewards Shop',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.juniorAppointedDash,
      screenId: ScreenId.appointedDriverDash,
      screenName: 'Appointed Driver Dash',
      allowedRoles: {UserRole.junior},
    ),
    RouteMeta(
      path: Routes.liveAppointed,
      screenId: ScreenId.appointedDriverLive,
      screenName: 'Appointed Driver Live',
      allowedRoles: {UserRole.junior},
    ),

    // Shared (GLOBAL)
    RouteMeta(
      path: Routes.sharedProfile,
      screenId: ScreenId.userProfile,
      screenName: 'User Profile',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
    RouteMeta(
      path: Routes.subscription,
      screenId: ScreenId.khawiSubscription,
      screenName: 'Khawi+ Subscription',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
    RouteMeta(
      path: Routes.sharedNotifications,
      screenId: ScreenId.notificationSettings,
      screenName: 'Notification Settings',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
    RouteMeta(
      path: Routes.sharedRewards,
      screenId: ScreenId.rewardsShop,
      screenName: 'Rewards Shop',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
    RouteMeta(
      path: Routes.sharedRedeem,
      screenId: ScreenId.redeemXp,
      screenName: 'Redeem XP Screen',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
    RouteMeta(
      path: Routes.sharedChallenges,
      screenId: ScreenId.weeklyChallenges,
      screenName: 'Weekly Challenges',
      allowedRoles: {UserRole.passenger, UserRole.driver, UserRole.junior},
    ),
  ];

  static RouteMeta? byPath(String path) {
    for (final m in all) {
      if (m.path == path) return m;
    }
    return null;
  }

  static RouteMeta byScreen(ScreenId id) =>
      all.firstWhere((m) => m.screenId == id);
}
