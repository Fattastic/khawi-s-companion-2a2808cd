import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/rating/domain/ride_rating.dart';

void main() {
  group('RideRating', () {
    const ts = '2026-02-16T10:00:00.000Z';
    final fullJson = <String, dynamic>{
      'id': 'rat1',
      'trip_id': 't1',
      'rater_id': 'u1',
      'rated_id': 'u2',
      'score': 5,
      'tags': ['on_time', 'friendly'],
      'comment': 'Great ride!',
      'created_at': ts,
    };

    test('fromJson parses all fields', () {
      final r = RideRating.fromJson(fullJson);
      expect(r.id, 'rat1');
      expect(r.tripId, 't1');
      expect(r.raterId, 'u1');
      expect(r.ratedId, 'u2');
      expect(r.score, 5);
      expect(r.tags, ['on_time', 'friendly']);
      expect(r.comment, 'Great ride!');
    });

    test('fromJson defaults', () {
      final r = RideRating.fromJson({
        'id': 'rat2',
        'trip_id': 't2',
        'rater_id': 'u3',
        'rated_id': 'u4',
        'created_at': ts,
      });
      expect(r.score, 5); // default
      expect(r.tags, isEmpty);
      expect(r.comment, isNull);
    });

    test('toJson round-trips', () {
      final r = RideRating.fromJson(fullJson);
      final j = r.toJson();
      expect(j['id'], 'rat1');
      expect(j['score'], 5);
      expect(j['tags'], ['on_time', 'friendly']);
      final r2 = RideRating.fromJson(j);
      expect(r2.id, r.id);
      expect(r2.score, r.score);
    });

    test('toInsertJson excludes id and created_at', () {
      final r = RideRating.fromJson(fullJson);
      final j = r.toInsertJson();
      expect(j.containsKey('id'), false);
      expect(j.containsKey('created_at'), false);
      expect(j['trip_id'], 't1');
      expect(j['score'], 5);
    });

    test('toInsertJson includes comment only if present', () {
      final withComment = RideRating.fromJson(fullJson);
      expect(withComment.toInsertJson().containsKey('comment'), true);

      final withoutComment = RideRating.fromJson({
        ...fullJson,
        'comment': null,
      });
      expect(withoutComment.toInsertJson().containsKey('comment'), false);
    });
  });

  group('RatingTag', () {
    test('all values exist', () {
      expect(RatingTag.values.length, 8);
    });

    test('label returns Arabic for ar locale', () {
      expect(RatingTag.onTime.label('ar'), 'في الموعد');
      expect(RatingTag.cleanCar.label('ar'), 'سيارة نظيفة');
    });

    test('label returns English for en locale', () {
      expect(RatingTag.onTime.label('en'), 'On Time');
      expect(RatingTag.safeDriver.label('en'), 'Safe Driver');
    });
  });

  group('RatingSummary', () {
    test('construction and formattedScore', () {
      const s = RatingSummary(
        averageScore: 4.567,
        totalRatings: 42,
        tagCounts: {'on_time': 10, 'friendly': 8},
      );
      expect(s.formattedScore, '4.6');
      expect(s.totalRatings, 42);
      expect(s.tagCounts['on_time'], 10);
    });

    test('default tagCounts is empty', () {
      const s = RatingSummary(averageScore: 5.0, totalRatings: 1);
      expect(s.tagCounts, isEmpty);
    });
  });
}
