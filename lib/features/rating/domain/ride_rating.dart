/// Rating model for post-ride bidirectional reviews.
///
/// Both drivers and passengers rate each other after trip completion.
class RideRating {
  final String id;
  final String tripId;

  /// The user who gave the rating.
  final String raterId;

  /// The user who received the rating.
  final String ratedId;

  /// Star score (1-5).
  final int score;

  /// Optional quick-select feedback tags.
  /// e.g. "on_time", "clean_car", "friendly", "smooth_driving", "great_conversation"
  final List<String> tags;

  /// Optional written review.
  final String? comment;

  final DateTime createdAt;

  const RideRating({
    required this.id,
    required this.tripId,
    required this.raterId,
    required this.ratedId,
    required this.score,
    this.tags = const [],
    this.comment,
    required this.createdAt,
  });

  factory RideRating.fromJson(Map<String, dynamic> j) => RideRating(
        id: j['id'] as String,
        tripId: j['trip_id'] as String,
        raterId: j['rater_id'] as String,
        ratedId: j['rated_id'] as String,
        score: (j['score'] as int?) ?? 5,
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
        comment: j['comment'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_id': tripId,
        'rater_id': raterId,
        'rated_id': ratedId,
        'score': score,
        'tags': tags,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  /// JSON shape for inserting into the database (no id, server sets created_at).
  Map<String, dynamic> toInsertJson() => {
        'trip_id': tripId,
        'rater_id': raterId,
        'rated_id': ratedId,
        'score': score,
        'tags': tags,
        if (comment != null) 'comment': comment,
      };
}

/// Predefined rating tags for quick selection.
enum RatingTag {
  onTime('on_time', 'في الموعد', 'On Time'),
  cleanCar('clean_car', 'سيارة نظيفة', 'Clean Car'),
  friendly('friendly', 'ودود', 'Friendly'),
  smoothDriving('smooth_driving', 'قيادة سلسة', 'Smooth Driving'),
  greatConversation('great_conversation', 'حديث ممتع', 'Great Chat'),
  safeDriver('safe_driver', 'سائق آمن', 'Safe Driver'),
  polite('polite', 'مؤدب', 'Polite'),
  comfortable('comfortable', 'مريح', 'Comfortable');

  final String key;
  final String labelAr;
  final String labelEn;

  const RatingTag(this.key, this.labelAr, this.labelEn);

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;
}

/// Aggregated rating summary for a user's profile display.
class RatingSummary {
  final double averageScore;
  final int totalRatings;
  final Map<String, int> tagCounts;

  const RatingSummary({
    required this.averageScore,
    required this.totalRatings,
    this.tagCounts = const {},
  });

  String get formattedScore => averageScore.toStringAsFixed(1);
}
