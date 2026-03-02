import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/driver/presentation/widgets/written_review_preview.dart';
import 'package:khawi_flutter/features/rating/domain/ride_rating.dart';

void main() {
  RideRating buildRating({
    int score = 5,
    String? comment,
    DateTime? createdAt,
  }) {
    return RideRating(
      id: 'r1',
      tripId: 't1',
      raterId: 'u1',
      ratedId: 'u2',
      score: score,
      comment: comment,
      createdAt: createdAt ?? DateTime(2026, 2, 16, 10, 30),
    );
  }

  group('buildWrittenReviewPreview', () {
    test('builds score and date headline with normalized body', () {
      final preview = buildWrittenReviewPreview(
        buildRating(score: 4, comment: 'Great   ride\nvery smooth'),
        isArabic: false,
      );

      expect(preview.headline, '★★★★☆ • 16/02/2026');
      expect(preview.body, 'Great ride very smooth');
    });

    test('truncates long comments with ellipsis', () {
      final preview = buildWrittenReviewPreview(
        buildRating(comment: '1234567890'),
        isArabic: false,
        maxChars: 6,
      );

      expect(preview.body, '12345…');
    });

    test('uses localized fallback when comment is missing', () {
      final english = buildWrittenReviewPreview(
        buildRating(comment: null),
        isArabic: false,
      );
      final arabic = buildWrittenReviewPreview(
        buildRating(comment: '  '),
        isArabic: true,
      );

      expect(english.body, 'No written review provided');
      expect(arabic.body, 'لا توجد مراجعة مكتوبة');
    });
  });
}
