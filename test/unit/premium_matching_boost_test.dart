import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/matching/domain/premium_matching_boost.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

void main() {
  Trip tripWithScore(int score, {List<String>? tags}) {
    return Trip(
      id: 't-$score',
      driverId: 'driver-1',
      originLat: 24.7,
      originLng: 46.6,
      destLat: 24.8,
      destLng: 46.7,
      departureTime: DateTime(2026, 2, 16, 9, 0),
      isRecurring: false,
      seatsTotal: 4,
      seatsAvailable: 3,
      womenOnly: false,
      isKidsRide: false,
      tags: const [],
      status: TripStatus.planned,
      matchScore: score,
      matchTags: tags,
    );
  }

  group('applyPremiumPriorityBoost', () {
    test('keeps trips unchanged for non-premium users', () {
      final trips = [tripWithScore(70)];

      final boosted = applyPremiumPriorityBoost(trips, isPremium: false);

      expect(boosted.first.matchScore, 70);
      expect(boosted.first.matchTags ?? const [],
          isNot(contains('Khawi+ priority')),);
    });

    test('adds score boost and Khawi+ priority tag for premium users', () {
      final trips = [
        tripWithScore(70, tags: const ['Quiet']),
      ];

      final boosted = applyPremiumPriorityBoost(trips, isPremium: true);

      expect(boosted.first.matchScore, 78);
      expect(boosted.first.matchTags, contains('Khawi+ priority'));
      expect(boosted.first.matchTags, contains('Quiet'));
    });

    test('caps boosted score at 100', () {
      final trips = [tripWithScore(97)];

      final boosted = applyPremiumPriorityBoost(trips, isPremium: true);

      expect(boosted.first.matchScore, 100);
    });
  });
}
