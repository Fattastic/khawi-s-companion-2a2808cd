import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/fare_estimate/domain/fare_estimate.dart';

void main() {
  group('calculateFareEstimate', () {
    test('computes total and per-passenger share', () {
      final estimate = calculateFareEstimate(
        distanceKm: 10,
        durationMinutes: 20,
        seatCount: 2,
      );

      expect(estimate.totalFareSar, closeTo(21.5, 0.001));
      expect(estimate.perPassengerFareSar, closeTo(10.75, 0.001));
    });

    test('normalizes invalid negatives and seat count', () {
      final estimate = calculateFareEstimate(
        distanceKm: -10,
        durationMinutes: -2,
        seatCount: 0,
      );

      expect(estimate.totalFareSar, closeTo(5.0, 0.001));
      expect(estimate.perPassengerFareSar, closeTo(5.0, 0.001));
      expect(estimate.seatCount, 1);
    });
  });
}
