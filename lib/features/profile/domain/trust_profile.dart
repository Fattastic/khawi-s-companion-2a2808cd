class TrustProfile {
  final String userId;
  final int trustScore;
  final String trustBadge; // 'bronze', 'silver', 'gold'
  final bool juniorTrusted;
  final DateTime computedAt;
  final Map<String, dynamic> evidence;

  const TrustProfile({
    required this.userId,
    required this.trustScore,
    required this.trustBadge,
    required this.juniorTrusted,
    required this.computedAt,
    required this.evidence,
  });

  factory TrustProfile.fromJson(Map<String, dynamic> json) {
    return TrustProfile(
      userId: json['user_id'] as String,
      trustScore: (json['trust_score'] as num).toInt(),
      trustBadge: json['trust_badge'] as String,
      juniorTrusted: (json['junior_trusted'] as bool?) ?? false,
      computedAt: DateTime.parse(json['computed_at'] as String),
      evidence: json['evidence'] as Map<String, dynamic>? ?? {},
    );
  }
}
