import 'gamification_enums.dart';

/// Snapshot of a user's commute streak state.
class StreakState {
  const StreakState({
    required this.userId,
    required this.currentCount,
    required this.longestCount,
    required this.status,
    required this.graceExpiresAt,
    required this.lastQualifyingTripAt,
    required this.updatedAt,
  });

  final String userId;
  final int currentCount;
  final int longestCount;
  final StreakStatus status;
  final DateTime? graceExpiresAt;
  final DateTime? lastQualifyingTripAt;
  final DateTime updatedAt;

  /// Whether streak is in grace window and can still be saved.
  bool get isRecoverable =>
      status == StreakStatus.grace &&
      graceExpiresAt != null &&
      graceExpiresAt!.isAfter(DateTime.now());

  factory StreakState.empty(String userId) => StreakState(
        userId: userId,
        currentCount: 0,
        longestCount: 0,
        status: StreakStatus.broken,
        graceExpiresAt: null,
        lastQualifyingTripAt: null,
        updatedAt: DateTime.now(),
      );

  factory StreakState.fromJson(Map<String, dynamic> json) => StreakState(
        userId: json['user_id'] as String,
        currentCount: json['current_count'] as int? ?? 0,
        longestCount: json['longest_count'] as int? ?? 0,
        status: StreakStatus.fromString(json['status'] as String? ?? 'broken'),
        graceExpiresAt: json['grace_expires_at'] != null
            ? DateTime.parse(json['grace_expires_at'] as String)
            : null,
        lastQualifyingTripAt: json['last_qualifying_trip_at'] != null
            ? DateTime.parse(json['last_qualifying_trip_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
}
