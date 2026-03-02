/// XP buckets for internal categorization.
/// Users see total XP only; buckets are invisible to end users.
class XpBuckets {
  /// XP from driving, carpooling, reliability
  final int contributionXp;

  /// XP from clean trips, kids safety, behavior
  final int safetyXp;

  /// XP from helping new users, streaks
  final int communityXp;

  /// XP from completing onboarding, safety tips
  final int learningXp;

  final DateTime updatedAt;

  const XpBuckets({
    required this.contributionXp,
    required this.safetyXp,
    required this.communityXp,
    required this.learningXp,
    required this.updatedAt,
  });

  /// Total XP across all buckets (what users see)
  int get totalXp => contributionXp + safetyXp + communityXp + learningXp;

  factory XpBuckets.fromJson(Map<String, dynamic> json) {
    return XpBuckets(
      contributionXp: (json['contribution_xp'] as num?)?.toInt() ?? 0,
      safetyXp: (json['safety_xp'] as num?)?.toInt() ?? 0,
      communityXp: (json['community_xp'] as num?)?.toInt() ?? 0,
      learningXp: (json['learning_xp'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Empty buckets for new users
  factory XpBuckets.empty() => XpBuckets(
        contributionXp: 0,
        safetyXp: 0,
        communityXp: 0,
        learningXp: 0,
        updatedAt: DateTime.now(),
      );
}
