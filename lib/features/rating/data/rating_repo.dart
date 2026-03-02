import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/ride_rating.dart';

/// Repository for managing ride ratings.
///
/// Handles submitting post-ride ratings and fetching rating summaries.
class RatingRepo {
  final SupabaseClient _client;
  static const _table = 'ride_ratings';

  RatingRepo(this._client);

  /// Submit a rating for a completed ride.
  ///
  /// Also updates the rated user's average_rating on their profile.
  Future<void> submitRating({
    required String tripId,
    required String raterId,
    required String ratedId,
    required int score,
    List<String> tags = const [],
    String? comment,
  }) async {
    // Insert the rating
    await _client.from(_table).insert({
      'trip_id': tripId,
      'rater_id': raterId,
      'rated_id': ratedId,
      'score': score,
      'tags': tags,
      if (comment != null) 'comment': comment,
    });

    // Update the rated user's average rating
    await _updateAverageRating(ratedId);
  }

  /// Get all ratings received by a user.
  Future<List<RideRating>> fetchRatingsFor(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('rated_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((j) => RideRating.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Get recent written reviews received by a user.
  ///
  /// This is optimized for UI surfaces that only need a small comment preview.
  Future<List<RideRating>> fetchWrittenReviewsFor(
    String userId, {
    int limit = 2,
  }) async {
    final queryLimit = limit < 2 ? 4 : limit * 3;
    final response = await _client
        .from(_table)
        .select()
        .eq('rated_id', userId)
        .not('comment', 'is', null)
        .order('created_at', ascending: false)
        .limit(queryLimit);

    final reviews = (response as List)
        .map((j) => RideRating.fromJson(j as Map<String, dynamic>))
        .where((rating) => (rating.comment?.trim().isNotEmpty ?? false))
        .take(limit)
        .toList(growable: false);

    return reviews;
  }

  /// Get the rating summary for a user.
  Future<RatingSummary> fetchRatingSummary(String userId) async {
    final ratings = await fetchRatingsFor(userId);

    if (ratings.isEmpty) {
      return const RatingSummary(averageScore: 0, totalRatings: 0);
    }

    final totalScore = ratings.fold<int>(0, (sum, r) => sum + r.score);
    final average = totalScore / ratings.length;

    // Count tag occurrences
    final tagCounts = <String, int>{};
    for (final rating in ratings) {
      for (final tag in rating.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    return RatingSummary(
      averageScore: average,
      totalRatings: ratings.length,
      tagCounts: tagCounts,
    );
  }

  /// Check if a user has already rated for a specific trip.
  Future<bool> hasRated({
    required String tripId,
    required String raterId,
  }) async {
    final response = await _client
        .from(_table)
        .select('id')
        .eq('trip_id', tripId)
        .eq('rater_id', raterId)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Recalculate and update average rating on the profiles table.
  Future<void> _updateAverageRating(String userId) async {
    final ratings =
        await _client.from(_table).select('score').eq('rated_id', userId);

    final scores = (ratings as List).map((r) => r['score'] as int).toList();
    if (scores.isEmpty) return;

    final avg = scores.reduce((a, b) => a + b) / scores.length;

    await _client.from('profiles').update({
      'average_rating': (avg * 10).roundToDouble() / 10, // 1 decimal place
      'total_ratings': scores.length,
    }).eq('id', userId);
  }
}
