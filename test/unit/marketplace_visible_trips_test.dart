import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/domain/marketplace_visible_trips.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

void main() {
  Trip trip({
    required String id,
    required String driverId,
    List<String> tags = const [],
    int? matchScore,
    int departureMinute = 0,
  }) {
    return Trip(
      id: id,
      driverId: driverId,
      originLat: 24.7,
      originLng: 46.6,
      destLat: 24.8,
      destLng: 46.7,
      departureTime: DateTime(2026, 2, 16, 8, departureMinute),
      isRecurring: false,
      seatsTotal: 4,
      seatsAvailable: 3,
      womenOnly: false,
      isKidsRide: false,
      tags: tags,
      status: TripStatus.active,
      matchScore: matchScore,
    );
  }

  group('buildVisibleMarketplaceTrips', () {
    test('returns original list when no filters and no favorites', () {
      final source = [
        trip(id: 'a', driverId: 'd1', matchScore: 60),
        trip(id: 'b', driverId: 'd2', matchScore: 70),
      ];

      final result = buildVisibleMarketplaceTrips(
        trips: source,
        businessOnly: false,
        campusOnly: false,
        eventOnly: false,
        selectedPreferences: const <String>{},
        favoriteDriverIds: const <String>{},
      );

      expect(identical(result, source), isTrue);
    });

    test('applies tag and preference filters', () {
      final source = [
        trip(id: 'a', driverId: 'd1', tags: const ['business_ride', 'quiet']),
        trip(id: 'b', driverId: 'd2', tags: const ['campus_ride', 'quiet']),
        trip(id: 'c', driverId: 'd3', tags: const ['business_ride']),
      ];

      final result = buildVisibleMarketplaceTrips(
        trips: source,
        businessOnly: true,
        campusOnly: false,
        eventOnly: false,
        selectedPreferences: const {'quiet'},
        favoriteDriverIds: const <String>{},
      );

      expect(result.map((t) => t.id).toList(), ['a']);
    });

    test('prioritizes favorite drivers then match score then departure', () {
      final source = [
        trip(
          id: 'a',
          driverId: 'd1',
          matchScore: 60,
          departureMinute: 30,
        ),
        trip(
          id: 'b',
          driverId: 'd2',
          matchScore: 90,
          departureMinute: 10,
        ),
        trip(
          id: 'c',
          driverId: 'd1',
          matchScore: 70,
          departureMinute: 20,
        ),
      ];

      final result = buildVisibleMarketplaceTrips(
        trips: source,
        businessOnly: false,
        campusOnly: false,
        eventOnly: false,
        selectedPreferences: const <String>{},
        favoriteDriverIds: const {'d1'},
      );

      expect(result.map((t) => t.id).toList(), ['c', 'a', 'b']);
    });
  });
}
