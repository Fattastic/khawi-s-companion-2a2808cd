import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/data/core/supabase_provider.dart';
import 'package:khawi_flutter/services/safety_service.dart';
import 'package:khawi_flutter/core/backend/backend_diagnostics.dart';
import 'package:khawi_flutter/features/auth/data/auth_repo.dart';
import 'package:khawi_flutter/features/profile/data/profile_repo.dart';
import 'package:khawi_flutter/features/profile/domain/profile_actions.dart';
import 'package:khawi_flutter/features/trips/data/trips_repo.dart';
import 'package:khawi_flutter/features/requests/data/requests_repo.dart';
import 'package:khawi_flutter/features/junior/data/junior_repo.dart';
import 'package:khawi_flutter/features/chat/data/chat_repo.dart';
import 'package:khawi_flutter/data/xp_repo.dart';
import 'package:khawi_flutter/features/xp_ledger/data/xp_ledger_repo.dart';
import 'package:khawi_flutter/features/rewards/data/rewards_repo.dart';
import 'package:khawi_flutter/features/notifications/data/notifications_repo.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/profile/data/trust_repo.dart';
import 'package:khawi_flutter/features/trips/data/incentive_repo.dart';
import 'package:khawi_flutter/features/subscription/data/subscription_repo.dart';
import 'package:khawi_flutter/features/support/data/support_repo.dart';
import 'package:khawi_flutter/services/match_service.dart';
import 'package:khawi_flutter/data/realtime/realtime_service.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/matching/data/edge_function_matching_gateway.dart';
import 'package:khawi_flutter/features/matching/data/mock_matching_gateway.dart';
import 'package:khawi_flutter/features/ride_history/data/ride_history_repo.dart';
import 'package:khawi_flutter/features/rating/data/rating_repo.dart';
import 'package:khawi_flutter/features/community/data/community_repo.dart';
import 'package:khawi_flutter/features/events/data/event_repo.dart';
import 'package:khawi_flutter/features/leaderboard/data/leaderboard_repo.dart';
import 'package:khawi_flutter/features/promo_codes/data/promo_codes_repo.dart';
import 'package:khawi_flutter/features/carbon/data/carbon_repo.dart';
import 'package:khawi_flutter/services/emergency_contacts_service.dart';
import 'package:khawi_flutter/services/favorite_drivers_service.dart';
import 'package:khawi_flutter/services/event_log_service.dart';
import 'package:khawi_flutter/features/gamification/data/streak_repo.dart';
import 'package:khawi_flutter/features/gamification/data/mission_repo.dart';
import 'package:khawi_flutter/features/gamification/data/wallet_repo.dart';
import 'package:khawi_flutter/features/gamification/data/progress_repo.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_event_service.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_lifecycle_hook.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_notifier.dart';
import 'package:khawi_flutter/features/circles/data/circle_repo.dart';

/// Provider for current time, allows overriding in tests.
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final profileRepoProvider = Provider(
  (ref) => ProfileRepo(ref.watch(supabaseProvider)),
);
final profileActionsProvider =
    Provider((ref) => ProfileActions(ref.watch(profileRepoProvider)));
final tripsRepoProvider = Provider(
  (ref) => TripsRepo(ref.watch(supabaseProvider)),
);
final requestsRepoProvider = Provider(
  (ref) => RequestsRepo(ref.watch(supabaseProvider)),
);
final juniorRepoProvider = Provider(
  (ref) => JuniorRepo(ref.watch(supabaseProvider)),
);
final chatRepoProvider = Provider(
  (ref) => ChatRepo(ref.watch(supabaseProvider)),
);
final xpRepoProvider = Provider((ref) => XpRepo(ref.watch(supabaseProvider)));
final xpLedgerRepoProvider =
    Provider((ref) => XpLedgerRepo(ref.watch(supabaseProvider)));
final rewardsRepoProvider =
    Provider((ref) => RewardsRepo(ref.watch(supabaseProvider)));
final notificationsRepoProvider =
    Provider((ref) => NotificationsRepo(ref.watch(supabaseProvider)));

final trustRepoProvider =
    Provider((ref) => TrustRepo(ref.watch(supabaseProvider)));
final incentiveRepoProvider =
    Provider((ref) => IncentiveRepo(ref.watch(supabaseProvider)));
final subscriptionRepoProvider =
    Provider((ref) => SubscriptionRepo(ref.watch(supabaseProvider)));
final supportRepoProvider =
    Provider((ref) => SupportRepo(ref.watch(supabaseProvider)));

// Ride history & rating repos
final rideHistoryRepoProvider =
    Provider((ref) => RideHistoryRepo(ref.watch(supabaseProvider)));
final ratingRepoProvider =
    Provider((ref) => RatingRepo(ref.watch(supabaseProvider)));

// Community & Event repos
final communityRepoProvider =
    Provider((ref) => CommunityRepo(ref.watch(supabaseProvider)));
final eventRepoProvider =
    Provider((ref) => EventRepo(ref.watch(supabaseProvider)));
final leaderboardRepoProvider =
    Provider((ref) => LeaderboardRepo(ref.watch(supabaseProvider)));
final promoCodesRepoProvider =
    Provider((ref) => PromoCodesRepo(ref.watch(supabaseProvider)));
final carbonRepoProvider =
    Provider((ref) => CarbonRepo(ref.watch(supabaseProvider)));

final circleRepoProvider = Provider((ref) => CircleRepo());

final emergencyContactsProvider = Provider((ref) => EmergencyContactsService());
final favoriteDriversProvider = Provider((ref) => FavoriteDriversService());
final eventLogProvider =
    Provider((ref) => EventLogService(ref.watch(supabaseProvider)));

// Gamification Tier-1 repos
final streakRepoProvider =
    Provider((ref) => StreakRepo(ref.watch(supabaseProvider)));
final missionRepoProvider =
    Provider((ref) => MissionRepo(ref.watch(supabaseProvider)));
final walletRepoProvider =
    Provider((ref) => WalletRepo(ref.watch(supabaseProvider)));
final progressRepoProvider =
    Provider((ref) => ProgressRepo(ref.watch(supabaseProvider)));
final gamificationEventServiceProvider =
    Provider((ref) => GamificationEventService(ref.watch(supabaseProvider)));

final gamificationNotifierProvider =
    Provider((ref) => GamificationNotifier(ref.watch(supabaseProvider)));

final gamificationHookProvider = Provider(
  (ref) => GamificationLifecycleHook(
    ref.watch(supabaseProvider),
    ref.watch(gamificationEventServiceProvider),
    ref.watch(gamificationNotifierProvider),
  ),
);

final matchServiceProvider =
    Provider((ref) => MatchService(ref.watch(supabaseProvider)));

// AI Matching Gateway - swappable between Edge Function, Node, or Mock
// Uses kUseDevMode flag to determine implementation
final matchingGatewayProvider = Provider<MatchingGateway>((ref) {
  if (kUseDevMode) {
    return MockMatchingGateway();
  }
  return EdgeFunctionMatchingGateway(ref.watch(supabaseProvider));
});

// Centralized realtime subscription service - prevents ghost listeners
final realtimeServiceProvider = Provider((ref) {
  final service = RealtimeService(ref.watch(supabaseProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

// Safety service wraps trip safety edge function + SOS RPC
final safetyServiceProvider = Provider((ref) => SafetyService());

// Backend diagnostics provider so widgets don't access Supabase directly
final backendDiagnosticsProvider =
    Provider((ref) => BackendDiagnostics(ref.watch(supabaseProvider)));

// Auth repository to centralize Supabase auth usage
final authRepoProvider =
    Provider((ref) => AuthRepo(ref.watch(supabaseProvider)));

// DEV MODE FLAG: Set to false to use real Supabase connection
const bool kUseDevMode = false;

final authSessionProvider = StreamProvider<Session?>((ref) {
  if (kUseDevMode) {
    // Return a fake session for dev mode
    return Stream.value(
      Session(
        accessToken: 'mock_token',
        tokenType: 'bearer',
        user: User(
          id: 'dev_user_id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
    );
  }
  final sb = ref.watch(supabaseProvider);

  // Emit current session immediately (important on cold start; onAuthStateChange
  // may not fire until a change happens).
  final controller = StreamController<Session?>.broadcast();
  controller.add(sb.auth.currentSession);
  final sub = sb.auth.onAuthStateChange.listen((e) {
    controller.add(e.session);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

final userIdProvider = Provider<String?>(
  (ref) => ref.watch(authSessionProvider).value?.user.id,
);

final debugProfileOverrideProvider = StateProvider<Profile?>((ref) => null);

final myProfileProvider = StreamProvider.autoDispose<Profile>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  // 1. Check for debug override first
  final override = ref.watch(debugProfileOverrideProvider);
  if (override != null) {
    return Stream.value(override);
  }

  if (kUseDevMode) {
    // Return a mock profile immediately
    return Stream.value(
      const Profile(
        id: 'dev_user_id',
        fullName: 'Dev User',
        role: UserRole.driver, // Logic to toggle this could be added later
        isPremium: true,
        isVerified: true,
        redeemableXp: 500,
        totalXp: 1500,
        avatarUrl: null,
      ),
    );
  }

  return ref.watch(profileRepoProvider).watchMyProfile(uid);
});

final roleProvider = Provider.autoDispose<UserRole?>((ref) {
  return ref.watch(
    myProfileProvider.select(
      (value) => value.maybeWhen(data: (p) => p.role, orElse: () => null),
    ),
  );
});

/// Single source of truth for premium status.
/// Use this provider for all premium gating instead of reading profile directly.
final premiumProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
    myProfileProvider.select(
      (value) => value.maybeWhen(data: (p) => p.isPremium, orElse: () => false),
    ),
  );
});

/// Single source of truth for driver verification status.
final verifiedProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
    myProfileProvider.select(
      (value) =>
          value.maybeWhen(data: (p) => p.isVerified, orElse: () => false),
    ),
  );
});

final activeChallengesProvider =
    FutureProvider.autoDispose<List<RewardChallenge>>((ref) {
  return ref.watch(rewardsRepoProvider).getActiveChallenges();
});

final roleSelectionCompletedProvider = Provider<bool>((ref) {
  return ref.watch(myProfileProvider).maybeWhen(
        data: (profile) => profile.role != null,
        orElse: () => false,
      );
});

/// Ensures the splash screen is visible for a minimum duration (e.g., 2 seconds)
/// to provide a premium branding experience and show the logo.
final splashWaitProvider = FutureProvider<void>((ref) async {
  // 2 seconds minimum duration
  await Future<void>.delayed(const Duration(seconds: 2));
});

final joinedCirclesProvider = StateProvider<Set<String>>((ref) => {});
