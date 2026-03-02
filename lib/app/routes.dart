/// Route registry for Khawi app.
///
/// Naming conventions:
/// - `/app/{role}/...` - Role-specific shell routes (p=passenger, d=driver, j=junior)
/// - `/auth/...` - Authentication flow routes
/// - `/live/...` - Fullscreen live trip routes
/// - `/shared/...` - Global shared features accessible from any role
abstract final class Routes {
  // ─────────────────────────────────────────────────────────────────────────
  // ENTRY & AUTH (canonical paths)
  // ─────────────────────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const authLogin = '/auth/login';
  static const authEmail = '/auth/email';
  static const authVerify = '/auth/verify';
  static const authRole = '/auth/role';
  static const authCallback = '/auth/callback';
  static const profileEnrichment = '/auth/enrichment';

  // ─────────────────────────────────────────────────────────────────────────
  // GATES & SPECIAL
  // ─────────────────────────────────────────────────────────────────────────
  static const verification = '/verification'; // Driver required
  static const subscription = '/subscription';

  // ─────────────────────────────────────────────────────────────────────────
  // PASSENGER SHELL (canonical: /app/p/...)
  // ─────────────────────────────────────────────────────────────────────────
  static const passengerHome = '/app/p/home';
  static const passengerSearch = '/app/p/search';
  static const passengerBooking = '/app/p/booking';
  static const passengerScan = '/app/p/instant/scan';
  static const passengerXpLedger = '/app/p/xp-ledger';
  static const passengerRewards = '/app/p/rewards';
  static const passengerProfile = '/app/p/profile';

  // Nested / Feature Alises (Canonicalized)
  static const passengerSearchAlias = '/app/p/home/search';
  static const passengerMarketplace = '/app/p/home/search';
  static const passengerTrips = '/app/p/home/trips';
  static const passengerExploreMap = '/app/p/home/explore-map';
  static const passengerPostRide = '/app/p/home/post-ride/:tripId';
  static const passengerHistory = '/app/p/home/history';

  // ─────────────────────────────────────────────────────────────────────────
  // DRIVER SHELL (canonical: /app/d/...)
  // ─────────────────────────────────────────────────────────────────────────
  static const driverDashboard = '/app/d/dashboard';
  static const driverQueue = '/app/d/queue';
  static const driverRewards = '/app/d/rewards';
  static const driverProfile = '/app/d/profile';
  static const driverPlanner = '/app/d/ai-planner';
  static const driverRegularTrips = '/app/d/regular-trips';
  static const driverInstantQr = '/app/d/instant/show-qr';

  // Feature Alises
  static const driverOfferRide = '/app/d/dashboard/offer-ride';
  static const driverExploreMap = '/app/d/dashboard/explore-map';
  static const driverHistory = '/app/d/dashboard/history';
  static const driverPostRide = '/app/d/dashboard/post-ride/:tripId';

  // ─────────────────────────────────────────────────────────────────────────
  // JUNIOR SHELL (canonical: /app/j/...)
  // ─────────────────────────────────────────────────────────────────────────
  static const juniorIntro = '/app/j/splash';
  static const juniorSafety = '/app/j/safety';
  static const juniorRoleSelection = '/app/j/role';
  static const juniorHub = '/app/j/hub';
  static const juniorCarpool = '/app/j/carpool';
  static const juniorRewards = '/app/j/rewards';
  static const juniorTracking = '/app/j/tracking';
  static const juniorMore = '/app/j/more';
  static const juniorAppointedDash = '/app/j/appointed/dashboard';

  // Feature Alises
  static const juniorAddDriver = '/app/j/hub/add-driver';

  // ─────────────────────────────────────────────────────────────────────────
  // LIVE TRIPS (fullscreen, no shell)
  // ─────────────────────────────────────────────────────────────────────────
  static const livePassenger = '/live/passenger/:tripId';
  static const liveDriver = '/live/driver/:tripId';
  static const liveJunior = '/live/junior/:tripId';
  static const liveAppointed = '/live/appointed/:tripId';
  static const chat = '/chat/:tripId';

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED FEATURES (accessible from any role)
  // ─────────────────────────────────────────────────────────────────────────
  static const sharedSubscription = '/shared/subscription';
  static const sharedRedeem = '/shared/redeem';
  static const sharedNotifications = '/shared/notifications';
  static const sharedProfile = '/shared/profile';
  static const sharedRewards = '/shared/rewards';
  static const sharedLeaderboard = '/shared/leaderboard';
  static const sharedPromoCodes = '/shared/promo-codes';
  static const sharedCarbon = '/shared/carbon';
  static const sharedFareEstimator = '/shared/fare-estimator';
  static const sharedSmartCommute = '/shared/smart-commute';
  static const sharedChallenges = '/shared/challenges';

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC DEEP LINK ENTRY POINTS (handled as App Links / Universal Links)
  // ─────────────────────────────────────────────────────────────────────────
  /// Referral / promo-code invite link.
  /// Share URL: https://khawi.app/invite/:code
  static const invite = '/invite/:code';

  /// Shareable live-trip link (passenger view by default; role redirect inside).
  /// Share URL: https://khawi.app/trip/:tripId
  static const publicTrip = '/trip/:tripId';
  static const referral = '/referral';

  // ─────────────────────────────────────────────────────────────────────────
  // COMMUNITIES & EVENTS
  // ─────────────────────────────────────────────────────────────────────────
  static const communities = '/shared/communities';
  static const communityDetail = '/shared/communities/:communityId';
  static const communityCreate = '/shared/communities/create';
  static const events = '/shared/events';
  static const eventDetail = '/shared/events/:eventId';

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR & DEVTOOLS
  // ─────────────────────────────────────────────────────────────────────────
  static const notFound = '/404';
  static const notAuthorized = '/not-authorized';
  static const devBackendDiagnostics = '/dev/backend-diagnostics';
  static const devMotionDiagnostics = '/dev/motion-diagnostics';
  static const about = '/about';
  static const settings = '/settings';
  static const helpCenter = '/help-center';
  static const trustTier = '/trust-tier';

  // ─────────────────────────────────────────────────────────────────────────
  // PATH HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  static String livePassengerPath(String tripId) => '/live/passenger/$tripId';
  static String liveDriverPath(String tripId) => '/live/driver/$tripId';
  static String liveJuniorPath(String tripId) => '/live/junior/$tripId';
  static String liveAppointedPath(String tripId) => '/live/appointed/$tripId';
  static String chatPath(String tripId) => '/chat/$tripId';
  static String passengerPostRidePath(String tripId) =>
      '/app/p/home/post-ride/$tripId';
  static String driverPostRidePath(String tripId) =>
      '/app/d/dashboard/post-ride/$tripId';
  static String communityDetailPath(String communityId) =>
      '/shared/communities/$communityId';
  static String eventDetailPath(String eventId) => '/shared/events/$eventId';
}
