import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/state/providers.dart';

import 'package:khawi_flutter/features/gamification/domain/streak_state.dart';
import 'package:khawi_flutter/features/gamification/domain/mission.dart';
import 'package:khawi_flutter/features/gamification/domain/next_best_action.dart';
import 'package:khawi_flutter/features/gamification/domain/wallet.dart';
import 'package:khawi_flutter/features/gamification/domain/progress_snapshot.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REPO PROVIDERS — registered centrally in state/providers.dart.
// Import state/providers.dart to access:
//   streakRepoProvider, missionRepoProvider, walletRepoProvider,
//   progressRepoProvider, gamificationEventServiceProvider,
//   gamificationHookProvider
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// DATA PROVIDERS — Parameterized by userId
// ═══════════════════════════════════════════════════════════════════════════════

/// Realtime streak state for the current user.
final streakProvider = StreamProvider.autoDispose<StreakState>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(streakRepoProvider).watchStreak(uid);
});

/// Realtime active missions for the current user.
final activeMissionsProvider = StreamProvider.autoDispose<List<Mission>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(missionRepoProvider).watchActiveMissions(uid);
});

/// Realtime wallet summary for the current user.
final walletSummaryProvider = StreamProvider.autoDispose<WalletSummary>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(walletRepoProvider).watchSummary(uid);
});

/// One-shot progress snapshot for post-trip or refresh surfaces.
final progressSnapshotProvider =
    FutureProvider.autoDispose<ProgressSnapshot>((ref) async {
  final uid = ref.watch(userIdProvider);
  final role = ref.watch(roleProvider);
  if (uid == null || role == null) return ProgressSnapshot.empty(uid ?? '');
  return ref
      .watch(progressRepoProvider)
      .getSnapshot(userId: uid, role: role.name);
});

/// Next-best-action recommendation for home card display.
final nextActionProvider =
    FutureProvider.autoDispose<NextBestAction?>((ref) async {
  final uid = ref.watch(userIdProvider);
  final role = ref.watch(roleProvider);
  if (uid == null || role == null) return null;
  return ref
      .watch(progressRepoProvider)
      .getNextAction(userId: uid, role: role.name);
});

/// Wallet transaction history with pagination support.
final walletHistoryProvider = FutureProvider.autoDispose
    .family<List<WalletTransaction>, ({int limit, int offset})>(
        (ref, params) async {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return [];
  return ref
      .watch(walletRepoProvider)
      .getHistory(uid, limit: params.limit, offset: params.offset);
});

/// Fires once per session to ensure weekly missions are assigned.
/// Watch this from the app root so it auto-triggers when the user logs in.
final gamificationInitProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return;
  await ref.read(gamificationHookProvider).ensureWeeklyMissions();
});
