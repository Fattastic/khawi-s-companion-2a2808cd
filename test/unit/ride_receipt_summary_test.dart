import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_receipt_summary.dart';

void main() {
  RideHistoryEntry baseEntry({DateTime? completedAt}) {
    return RideHistoryEntry(
      tripId: 'trip_abcdef123',
      requestId: 'req_123456',
      originLabel: 'Olaya',
      destLabel: 'KAFD',
      originLat: 24.7,
      originLng: 46.6,
      destLat: 24.8,
      destLng: 46.7,
      departureTime: DateTime(2026, 2, 16, 8, 0),
      completedAt: completedAt,
      status: 'completed',
      distanceKm: 12.0,
    );
  }

  group('buildRideReceiptSummary', () {
    test('uses derived duration from completedAt when available', () {
      final summary = buildRideReceiptSummary(
        baseEntry(completedAt: DateTime(2026, 2, 16, 8, 35)),
      );

      expect(summary.durationMinutes, 35);
      expect(summary.receiptNumber, startsWith('KHW-20260216-'));
      expect(summary.estimatedFareSar, greaterThan(0));
    });

    test('falls back to default duration when completedAt missing', () {
      final summary = buildRideReceiptSummary(
        baseEntry(),
        fallbackDurationMinutes: 25,
      );

      expect(summary.durationMinutes, 25);
      expect(summary.estimatedPerPassengerSar, greaterThan(0));
    });
  });
}
