import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service that handles the in-app store rating prompt.
///
/// UX contract (§2.5 / FT-20):
///  - Prompt shown after the user's 5th completed trip, OR after any trip
///    they rate 5 stars.
///  - Never shown before 3 completed trips.
///  - Never shown more than once per 60 days.
///  - Never shown during an active trip or safety-critical flow.
class StoreRatingService {
  StoreRatingService(this._review);

  final InAppReview _review;

  static const _kTripCountKey = 'store_rating_trip_count';
  static const _kLastPromptKey = 'store_rating_last_prompt_ms';
  static const _kMinTrips = 3;
  static const _kTriggerTrips = 5;
  static const _kCooldownDays = 60;

  /// Call after every successful trip completion.
  ///
  /// Pass [fiveStarRating] = true when the user just gave a 5-star rating
  /// to trigger an immediate eligibility check at the best possible moment.
  Future<void> onTripCompleted({bool fiveStarRating = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Increment trip counter.
    final count = (prefs.getInt(_kTripCountKey) ?? 0) + 1;
    await prefs.setInt(_kTripCountKey, count);

    // Gate: must have at least _kMinTrips trips.
    if (count < _kMinTrips) return;

    // Gate: cooldown — don't re-prompt within _kCooldownDays.
    final lastMs = prefs.getInt(_kLastPromptKey) ?? 0;
    final daysSinceLast = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastMs))
        .inDays;
    if (lastMs > 0 && daysSinceLast < _kCooldownDays) return;

    // Trigger: 5-star rating OR hit the nth-trip milestone.
    final shouldPrompt = fiveStarRating || (count == _kTriggerTrips);
    if (!shouldPrompt) return;

    await _requestReview(prefs);
  }

  Future<void> _requestReview(SharedPreferences prefs) async {
    final available = await _review.isAvailable();
    if (!available) return;

    await prefs.setInt(
      _kLastPromptKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _review.requestReview();
  }
}
