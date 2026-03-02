import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/driver/domain/smart_route_suggestion.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

void main() {
  Trip plannedTrip({
    required String id,
    required DateTime departure,
    bool recurring = false,
    int? score,
    double? distanceKm,
    String? originLabel,
    String? destLabel,
  }) {
    return Trip(
      id: id,
      driverId: 'd1',
      originLat: 24.7,
      originLng: 46.6,
      destLat: 24.8,
      destLng: 46.7,
      originLabel: originLabel ?? 'Origin $id',
      destLabel: destLabel ?? 'Dest $id',
      departureTime: departure,
      isRecurring: recurring,
      seatsTotal: 4,
      seatsAvailable: 3,
      womenOnly: false,
      isKidsRide: false,
      tags: const [],
      status: TripStatus.planned,
      matchScore: score,
      distanceKm: distanceKm,
    );
  }

  group('buildSmartRouteSuggestions', () {
    test('prioritizes recurring then match score', () {
      final now = DateTime(2026, 2, 16, 8, 0);
      final trips = [
        plannedTrip(
            id: 'a',
            departure: now.add(const Duration(minutes: 40)),
            score: 95,),
        plannedTrip(
          id: 'b',
          departure: now.add(const Duration(minutes: 50)),
          recurring: true,
          score: 70,
        ),
        plannedTrip(
            id: 'c',
            departure: now.add(const Duration(minutes: 30)),
            score: 80,),
      ];

      final suggestions =
          buildSmartRouteSuggestions(trips, now: now, maxResults: 3);

      expect(suggestions.length, 3);
      expect(suggestions.first.title, contains('Origin b'));
      expect(suggestions[1].title, contains('Origin a'));
      expect(suggestions[2].title, contains('Origin c'));
    });

    test('filters out stale planned trips and bounds duration', () {
      final now = DateTime(2026, 2, 16, 8, 0);
      final trips = [
        plannedTrip(
            id: 'old',
            departure: now.subtract(const Duration(hours: 2)),
            distanceKm: 300,),
        plannedTrip(
            id: 'new',
            departure: now.add(const Duration(minutes: 15)),
            distanceKm: 1,),
      ];

      final suggestions =
          buildSmartRouteSuggestions(trips, now: now, maxResults: 3);

      expect(suggestions.length, 1);
      expect(suggestions.first.title, contains('Origin new'));
      expect(suggestions.first.estimatedDurationMinutes, 12);
    });
  });

  group('detectCommutePatterns', () {
    test('groups trips by route and hour bucket then ranks patterns', () {
      final trips = [
        plannedTrip(
          id: 'p1',
          departure: DateTime(2026, 2, 16, 8, 10),
          recurring: true,
          score: 85,
          originLabel: 'King Saud University',
          destLabel: 'Olaya Towers',
        ),
        plannedTrip(
          id: 'p2',
          departure: DateTime(2026, 2, 17, 8, 40),
          recurring: true,
          score: 80,
          originLabel: 'King Saud University',
          destLabel: 'Olaya Towers',
        ),
        plannedTrip(
          id: 'p3',
          departure: DateTime(2026, 2, 16, 18, 20),
          recurring: false,
          score: 70,
        ),
      ];

      final patterns = detectCommutePatterns(trips, maxResults: 3);

      expect(patterns, isNotEmpty);
      expect(patterns.first.frequency, 2);
      expect(patterns.first.timeWindowLabel, contains('08:00'));
      expect(patterns.first.isPeakWindow, isTrue);
    });

    test('respects max results and ignores non-planned trips', () {
      final planned = plannedTrip(
        id: 'a1',
        departure: DateTime(2026, 2, 16, 7, 30),
        score: 90,
      );
      final active = planned.copyWith(status: TripStatus.active);

      final patterns = detectCommutePatterns([planned, active], maxResults: 1);

      expect(patterns.length, 1);
      expect(patterns.first.frequency, 1);
    });
  });
}
