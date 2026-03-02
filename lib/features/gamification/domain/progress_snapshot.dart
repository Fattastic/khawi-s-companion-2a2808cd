import 'streak_state.dart';
import 'mission.dart';
import 'wallet.dart';
import 'next_best_action.dart';

/// Unified read-only progress snapshot returned by the progress API.
/// Used for post-trip cards and role-home surfaces.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.userId,
    required this.streak,
    required this.activeMissions,
    required this.walletSummary,
    required this.nextAction,
    required this.fetchedAt,
  });

  final String userId;
  final StreakState streak;
  final List<Mission> activeMissions;
  final WalletSummary walletSummary;
  final NextBestAction? nextAction;
  final DateTime fetchedAt;

  /// Number of missions in progress or available.
  int get pendingMissionCount =>
      activeMissions.where((m) => !m.isComplete && !m.isExpired).length;

  /// Number of completed missions this week.
  int get completedMissionCount =>
      activeMissions.where((m) => m.isComplete).length;

  factory ProgressSnapshot.empty(String userId) => ProgressSnapshot(
        userId: userId,
        streak: StreakState.empty(userId),
        activeMissions: const [],
        walletSummary: WalletSummary.empty(userId),
        nextAction: null,
        fetchedAt: DateTime.now(),
      );

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final userId = json['user_id'] as String;
    return ProgressSnapshot(
      userId: userId,
      streak: json['streak'] != null
          ? StreakState.fromJson(json['streak'] as Map<String, dynamic>)
          : StreakState.empty(userId),
      activeMissions: json['active_missions'] != null
          ? (json['active_missions'] as List)
              .map((e) => Mission.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      walletSummary: json['wallet_summary'] != null
          ? WalletSummary.fromJson(
              json['wallet_summary'] as Map<String, dynamic>,
            )
          : WalletSummary.empty(userId),
      nextAction: json['next_action'] != null
          ? NextBestAction.fromJson(
              json['next_action'] as Map<String, dynamic>,
            )
          : null,
      fetchedAt: DateTime.now(),
    );
  }
}
