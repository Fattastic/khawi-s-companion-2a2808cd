import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_receipt_export.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_receipt_summary.dart';

void main() {
  RideHistoryEntry buildEntry({
    String? originLabel,
    String? destLabel,
    DateTime? completedAt,
    double? distanceKm = 12.5,
    int? xpEarned = 55,
  }) {
    return RideHistoryEntry(
      tripId: 'trip_abc123',
      requestId: 'req_1',
      originLabel: originLabel,
      destLabel: destLabel,
      originLat: 24.7,
      originLng: 46.6,
      destLat: 24.8,
      destLng: 46.7,
      departureTime: DateTime(2026, 2, 16, 8),
      completedAt: completedAt,
      status: 'completed',
      distanceKm: distanceKm,
      xpEarned: xpEarned,
    );
  }

  const summary = RideReceiptSummary(
    receiptNumber: 'KHW-20260216-tripab',
    durationMinutes: 30,
    estimatedFareSar: 21.5,
    estimatedPerPassengerSar: 10.75,
  );

  group('buildRideReceiptExportText', () {
    test('builds english receipt export text with route and fare fields', () {
      final text = buildRideReceiptExportText(
        entry: buildEntry(originLabel: 'Olaya', destLabel: 'KAFD'),
        summary: summary,
        isArabic: false,
      );

      expect(text, contains('Receipt: KHW-20260216-tripab'));
      expect(text, contains('From: Olaya'));
      expect(text, contains('To: KAFD'));
      expect(text, contains('Estimated Fare: 21.50 SAR'));
      expect(text, contains('Per Passenger: 10.75 SAR'));
      expect(text, contains('XP Earned: +55 XP'));
    });

    test('uses arabic labels and fallback values when fields are missing', () {
      final text = buildRideReceiptExportText(
        entry: buildEntry(
          originLabel: null,
          destLabel: null,
          completedAt: null,
          distanceKm: null,
          xpEarned: null,
        ),
        summary: summary,
        isArabic: true,
      );

      expect(text, contains('الإيصال: KHW-20260216-tripab'));
      expect(text, contains('من: نقطة الانطلاق'));
      expect(text, contains('إلى: الوجهة'));
      expect(text, contains('الاكتمال: غير متاح'));
      expect(text, contains('المسافة: غير متاح'));
      expect(text, contains('نقاط XP: +45 XP'));
    });
  });
}
