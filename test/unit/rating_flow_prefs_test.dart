import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/rating/domain/rating_flow_prefs.dart';
import 'package:khawi_flutter/features/rating/domain/ride_rating.dart';

void main() {
  group('defaultRatingTags', () {
    test('driver direction includes safety and comfort oriented tags', () {
      final tags = defaultRatingTags(RatingDirection.rateDriver);

      expect(tags, contains(RatingTag.safeDriver));
      expect(tags, contains(RatingTag.cleanCar));
      expect(tags, contains(RatingTag.comfortable));
    });

    test(
        'passenger direction includes politeness tags and excludes driver-only tags',
        () {
      final tags = defaultRatingTags(RatingDirection.ratePassenger);

      expect(tags, contains(RatingTag.polite));
      expect(tags, contains(RatingTag.greatConversation));
      expect(tags, isNot(contains(RatingTag.safeDriver)));
      expect(tags, isNot(contains(RatingTag.cleanCar)));
    });
  });
}
