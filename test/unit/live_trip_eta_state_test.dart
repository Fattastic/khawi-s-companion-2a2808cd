import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/live_trip/presentation/live_trip_passenger_screen.dart';

void main() {
  group('deriveArrivalDetectedAt', () {
    final now = DateTime(2026, 2, 16, 12, 0, 0);

    test('sets arrival timestamp when ETA <= 0 and no existing timestamp', () {
      final result = deriveArrivalDetectedAt(
        etaMinutes: 0,
        currentArrivalDetectedAt: null,
        now: now,
      );

      expect(result, now);
    });

    test('preserves existing arrival timestamp when ETA <= 0', () {
      final existing = DateTime(2026, 2, 16, 11, 59, 30);
      final result = deriveArrivalDetectedAt(
        etaMinutes: -1,
        currentArrivalDetectedAt: existing,
        now: now,
      );

      expect(result, existing);
    });

    test('clears arrival timestamp when ETA becomes positive', () {
      final existing = DateTime(2026, 2, 16, 11, 59, 30);
      final result = deriveArrivalDetectedAt(
        etaMinutes: 3,
        currentArrivalDetectedAt: existing,
        now: now,
      );

      expect(result, isNull);
    });

    test('clears arrival timestamp when ETA is unknown', () {
      final existing = DateTime(2026, 2, 16, 11, 59, 30);
      final result = deriveArrivalDetectedAt(
        etaMinutes: null,
        currentArrivalDetectedAt: existing,
        now: now,
      );

      expect(result, isNull);
    });
  });
}
