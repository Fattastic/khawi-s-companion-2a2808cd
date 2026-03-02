import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/carbon/domain/carbon_summary.dart';

void main() {
  group('summarizeCarbonTrips', () {
    test('returns empty summary for empty input', () {
      final summary = summarizeCarbonTrips(const <CarbonTripImpact>[]);

      expect(summary.totalCo2SavedKg, 0);
      expect(summary.totalDistanceKm, 0);
      expect(summary.tripsCount, 0);
      expect(summary.averageCo2PerTripKg, 0);
      expect(summary.equivalentTreeMonths, 0);
    });

    test('aggregates co2 and distance correctly', () {
      final summary = summarizeCarbonTrips([
        CarbonTripImpact(
          tripId: 't1',
          departureTime: DateTime(2026, 2, 1),
          originLabel: 'A',
          destLabel: 'B',
          co2SavedKg: 1.2,
          distanceKm: 10,
        ),
        CarbonTripImpact(
          tripId: 't2',
          departureTime: DateTime(2026, 2, 2),
          originLabel: 'C',
          destLabel: 'D',
          co2SavedKg: 2.8,
          distanceKm: 20,
        ),
      ]);

      expect(summary.totalCo2SavedKg, 4.0);
      expect(summary.totalDistanceKm, 30.0);
      expect(summary.tripsCount, 2);
      expect(summary.averageCo2PerTripKg, 2.0);
      expect(summary.equivalentTreeMonths, greaterThan(2.1));
      expect(summary.recentImpacts.length, 2);
    });
  });
}
