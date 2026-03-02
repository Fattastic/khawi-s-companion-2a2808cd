class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final int totalXp;
  final String? trustBadge;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalXp,
    this.trustBadge,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as String? ?? '',
      displayName: (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? (json['display_name'] as String).trim()
          : 'Khawi User',
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      trustBadge: json['trust_badge'] as String?,
    );
  }

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? displayName,
    int? totalXp,
    String? trustBadge,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      totalXp: totalXp ?? this.totalXp,
      trustBadge: trustBadge ?? this.trustBadge,
    );
  }
}

List<LeaderboardEntry> assignLeaderboardRanks(List<LeaderboardEntry> items) {
  final sorted = [...items]..sort((a, b) {
      final byXp = b.totalXp.compareTo(a.totalXp);
      if (byXp != 0) return byXp;
      return a.displayName.compareTo(b.displayName);
    });

  return List<LeaderboardEntry>.generate(
    sorted.length,
    (index) => sorted[index].copyWith(rank: index + 1),
    growable: false,
  );
}
