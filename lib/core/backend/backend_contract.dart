/// Backend Contract Registry
/// Single source of truth for all backend identifiers: Edge Functions, Tables, Columns, RPCs.
/// This eliminates hardcoded strings and ensures consistency across the codebase.
library;

// =============================================================================
// EDGE FUNCTIONS
// =============================================================================

/// Edge Function names deployed to Supabase
abstract class EdgeFn {
  EdgeFn._();

  /// AI Module A: Score trip matches for passenger
  static const scoreMatches = 'score_matches';

  /// AI Module A: Smart match - find and score trips in one call
  static const smartMatch = 'smart_match';

  /// AI Module B: Bundle passenger stops for driver
  static const bundleStops = 'bundle_stops';

  /// AI Module C: Compute dynamic XP incentives based on location/time
  static const computeIncentives = 'compute_incentives';

  /// AI Module D: Compute trust scores for users
  static const computeTrustScores = 'compute_trust_scores';

  /// AI Module E: Moderate chat messages
  static const moderateMessage = 'moderate_message';

  /// AI Module H: Detect fraud patterns (batch job)
  static const detectFraud = 'detect_fraud';

  /// Real-time trip safety check
  static const checkTripSafety = 'check_trip_safety';

  /// Verify identity (Nafath/Absher)
  static const verifyIdentity = 'verify_identity';

  /// Calculate XP awards (server-side)
  static const xpCalculate = 'xp_calculate';

  /// AI Support Copilot
  static const supportCopilot = 'support_copilot';

  /// Compute area incentives
  static const computeAreaIncentives = 'compute_area_incentives';

  /// Predict acceptance probability
  static const predictAcceptance = 'predict_acceptance';

  /// Create Stripe checkout session
  static const createCheckoutSession = 'create_checkout_session';

  /// Stripe webhook handler
  static const stripeWebhook = 'stripe_webhook';
  static const etaEstimation = 'eta_estimation';
  static const predictDemand = 'predict_demand';
  static const driverBehaviorScoring = 'driver_behavior_scoring';

  // Aligned Rewards & Trust (new)
  static const redeemReward = 'redeem_reward';
  static const getTrustState = 'get_trust_state';
  static const listUserBadges = 'list_user_badges';
  static const classifyXpBucket = 'classify_xp_bucket';
  static const computeTrustTier = 'compute_trust_tier';
  static const evaluateBadges = 'evaluate_badges';

  // Gamification Tier-1
  static const getProgressSnapshot = 'get_progress_snapshot';
  static const getNextAction = 'get_next_action';

  // Gamification Sprint 3
  static const getWalletSummary = 'get_wallet_summary';
  static const getWalletHistory = 'get_wallet_history';
}

// =============================================================================
// DATABASE TABLES
// =============================================================================

/// Database table names
abstract class DbTable {
  DbTable._();

  // Core tables
  static const profiles = 'profiles';
  static const trips = 'trips';
  static const tripRequests = 'trip_requests';
  static const profileWithTrust = 'profile_with_trust';

  // Realtime tables
  static const tripMessages = 'trip_messages';
  static const tripLocations = 'trip_locations';

  // Junior module
  static const kids = 'kids';
  static const juniorRuns = 'junior_runs';
  static const juniorRunEvents = 'junior_run_events';
  static const juniorRunLocations = 'junior_run_locations';
  static const juniorDriverGrants = 'junior_driver_grants';
  static const juniorInviteCodes = 'junior_invite_codes';
  static const trustedDrivers = 'trusted_drivers';
  static const sosEvents = 'sos_events';

  // AI/ML tables
  static const matchScores = 'match_scores';
  static const trustProfiles = 'trust_profiles';
  static const areaIncentives = 'area_incentives';
  static const fraudFlags = 'fraud_flags';
  static const moderationEvents = 'moderation_events';

  // Gamification
  static const xpEvents = 'xp_events';
  static const xpRules = 'xp_rules';
  static const userGamification = 'user_gamification';
  static const rewards = 'rewards';
  static const rewardRedemptions = 'reward_redemptions';

  // Gamification Tier-1 (Streak / Mission / Wallet)
  static const userStreaks = 'user_streaks';
  static const userMissions = 'user_missions';
  static const userWalletSummary = 'user_wallet_summary';
  static const walletTransactions = 'wallet_transactions';
  static const experimentCohorts = 'experiment_cohorts';

  // Gamification Sprint 3
  static const walletPolicy = 'wallet_policy';
  static const gamificationFraudGuard = 'gamification_fraud_guard';
  static const nbaClickEvents = 'nba_click_events';

  // Aligned Rewards & Trust (new)
  static const rewardsCatalog = 'rewards_catalog';
  static const badgesCatalog = 'badges_catalog';
  static const userBadgesV2 = 'user_badges_v2';
  static const userTrustState = 'user_trust_state';
  static const trustEvents = 'trust_events';

  // Ratings & Reviews
  static const rideRatings = 'ride_ratings';

  // Communities
  static const communities = 'communities';
  static const communityMembers = 'community_members';
  static const communityRides = 'community_rides';

  // Events
  static const events = 'events';
  static const eventRides = 'event_rides';
  static const eventInterest = 'event_interest';

  // Support
  static const supportTickets = 'support_tickets';
  static const supportAiOutputs = 'support_ai_outputs';

  // System
  static const featureFlags = 'feature_flags';
  static const eventLog = 'event_log';
  static const notifications = 'notifications';
}

// =============================================================================
// RPC FUNCTIONS
// =============================================================================

/// Supabase RPC function names
abstract class DbRpc {
  DbRpc._();

  // Trip requests
  static const sendJoinRequest = 'send_join_request';
  static const cancelJoinRequest = 'cancel_join_request';
  static const driverAcceptRequest = 'driver_accept_request';
  static const driverDeclineRequest = 'driver_decline_request';
  static const updateRequestStatus = 'update_request_status';

  // Junior module
  static const createRunGrantAndAssignDriver =
      'create_run_grant_and_assign_driver';
  static const revokeDriverGrant = 'revoke_driver_grant';
  static const updateJuniorRunStatus = 'update_junior_run_status';
  static const createJuniorInviteCode = 'create_junior_invite_code';
  static const redeemJuniorInviteCode = 'redeem_junior_invite_code';
  static const driverPushJuniorLocation = 'driver_push_junior_location';

  // Safety
  static const createSos = 'create_sos';
  static const updateSosStatus = 'update_sos_status';

  // XP
  static const awardTripXp = 'award_trip_xp';
  static const redeemXpPremium = 'redeem_xp_premium';

  // Gamification Tier-1
  static const evaluateStreakOnTrip = 'evaluate_streak_on_trip';
  static const evaluateMissionProgress = 'evaluate_mission_progress';
  static const assignWeeklyMissions = 'assign_weekly_missions';
  static const computeWalletSummary = 'compute_wallet_summary';
  static const assignExperimentCohort = 'assign_experiment_cohort';

  // Gamification Sprint 3
  static const checkGamificationFraudGuard = 'check_gamification_fraud_guard';
}

// =============================================================================
// COMMON COLUMN NAMES
// =============================================================================

/// Common database column names used across tables
abstract class DbCol {
  DbCol._();

  // Common
  static const id = 'id';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const status = 'status';
  static const isRead = 'is_read';

  // Profile columns
  static const fullName = 'full_name';
  static const avatarUrl = 'avatar_url';
  static const role = 'role';
  static const isPremium = 'is_premium';
  static const isVerified = 'is_verified';
  static const totalXp = 'total_xp';
  static const redeemableXp = 'redeemable_xp';
  static const gender = 'gender';
  static const neighborhoodId = 'neighborhood_id';
  static const xpThrottle = 'xp_throttle';
  static const xpThrottleUntil = 'xp_throttle_until';

  // Subscription columns
  static const stripeCustomerId = 'stripe_customer_id';
  static const subscriptionStatus = 'subscription_status';

  // Rating columns
  static const averageRating = 'average_rating';
  static const totalRatings = 'total_ratings';
  static const score = 'score';
  static const raterId = 'rater_id';
  static const ratedId = 'rated_id';
  static const comment = 'comment';

  // Trip columns
  static const driverId = 'driver_id';
  static const passengerId = 'passenger_id';
  static const tripId = 'trip_id';
  static const originLat = 'origin_lat';
  static const originLng = 'origin_lng';
  static const destLat = 'dest_lat';
  static const destLng = 'dest_lng';
  static const originLabel = 'origin_label';
  static const destLabel = 'dest_label';
  static const polyline = 'polyline';
  static const departureTime = 'departure_time';
  static const isRecurring = 'is_recurring';
  static const scheduleJson = 'schedule_json';
  static const seatsTotal = 'seats_total';
  static const seatsAvailable = 'seats_available';
  static const womenOnly = 'women_only';
  static const isKidsRide = 'is_kids_ride';
  static const tags = 'tags';

  // Trust/AI columns
  static const trustScore = 'trust_score';
  static const trustBadge = 'trust_badge';
  static const juniorTrusted = 'junior_trusted';
  static const matchScore = 'match_score';
  static const acceptProb = 'accept_prob';
  static const explanationTags = 'explanation_tags';

  // Junior columns
  static const parentId = 'parent_id';
  static const kidId = 'kid_id';
  static const runId = 'run_id';
  static const assignedDriverId = 'assigned_driver_id';
  static const pickupLat = 'pickup_lat';
  static const pickupLng = 'pickup_lng';
  static const dropoffLat = 'dropoff_lat';
  static const dropoffLng = 'dropoff_lng';
  static const pickupTime = 'pickup_time';

  // Location columns
  static const lat = 'lat';
  static const lng = 'lng';
  static const heading = 'heading';
  static const speed = 'speed';
  static const accuracy = 'accuracy';
  static const userId = 'user_id';

  // Message columns
  static const senderId = 'sender_id';
  static const body = 'body';
  static const moderationStatus = 'moderation_status';
  static const flaggedReason = 'flagged_reason';
}

// =============================================================================
// EDGE FUNCTION RESPONSE KEYS
// =============================================================================

/// JSON keys expected in Edge Function responses
abstract class EdgeRes {
  EdgeRes._();

  // score_matches response
  static const matches = 'matches';
  static const tripIdKey = 'trip_id';
  static const matchScoreKey = 'match_score';
  static const acceptProbKey = 'accept_prob';
  static const explanationTagsKey = 'explanation_tags';

  // bundle_stops response
  static const suggestion = 'suggestion';
  static const rankScore = 'rank_score';
  static const stops = 'stops';
  static const skipped = 'skipped';
  static const reason = 'reason';

  // compute_incentives response
  static const multiplier = 'multiplier';
  static const areaId = 'area_id';
  static const validUntil = 'valid_until';

  // check_trip_safety response
  static const riskScore = 'risk_score';
  static const alerts = 'alerts';
  static const recommendations = 'recommendations';

  // Common error keys
  static const error = 'error';
  static const hint = 'hint';
}

// =============================================================================
// STATUS ENUMS (as string constants matching DB constraints)
// =============================================================================

/// Trip status values
abstract class TripStatusValue {
  TripStatusValue._();

  static const planned = 'planned';
  static const active = 'active';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

/// Request status values
abstract class RequestStatusValue {
  RequestStatusValue._();

  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
  static const cancelled = 'cancelled';
  static const expired = 'expired';
}

/// Junior run status values
abstract class JuniorRunStatusValue {
  JuniorRunStatusValue._();

  static const planned = 'planned';
  static const driverAssigned = 'driver_assigned';
  static const pickedUp = 'picked_up';
  static const arrived = 'arrived';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

/// Moderation status values
abstract class ModerationStatusValue {
  ModerationStatusValue._();

  static const pending = 'pending';
  static const approved = 'approved';
  static const flagged = 'flagged';
  static const blocked = 'blocked';
}
