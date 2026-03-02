import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/presentation/booking_confirmation_screen.dart';

void main() {
  group('formatDepartureRelativeLabel', () {
    final now = DateTime(2026, 2, 16, 10, 0);

    test('returns departing now for current or past departure', () {
      expect(
        formatDepartureRelativeLabel(
          isArabic: false,
          departureTime: now,
          now: now,
        ),
        'Departing now',
      );
      expect(
        formatDepartureRelativeLabel(
          isArabic: true,
          departureTime: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        'انطلاق الآن',
      );
    });

    test('formats minute and hour windows correctly', () {
      expect(
        formatDepartureRelativeLabel(
          isArabic: false,
          departureTime: now.add(const Duration(minutes: 25)),
          now: now,
        ),
        'Departs in 25 min',
      );
      expect(
        formatDepartureRelativeLabel(
          isArabic: false,
          departureTime: now.add(const Duration(hours: 2, minutes: 15)),
          now: now,
        ),
        'Departs in 2h 15m',
      );
      expect(
        formatDepartureRelativeLabel(
          isArabic: true,
          departureTime: now.add(const Duration(hours: 1)),
          now: now,
        ),
        'ينطلق بعد 1 س',
      );
    });
  });

  group('formatRouteSummary', () {
    test('uses clean origin and destination when available', () {
      final text = formatRouteSummary(
        pickupFallback: 'Pickup',
        destinationFallback: 'Destination',
        originLabel: 'Riyadh',
        destinationLabel: 'Jeddah',
      );

      expect(text, 'Riyadh → Jeddah');
    });

    test('falls back when labels are placeholders', () {
      final text = formatRouteSummary(
        pickupFallback: 'Pickup',
        destinationFallback: 'Destination',
        originLabel: 'N/A',
        destinationLabel: 'null',
      );

      expect(text, 'Pickup → Destination');
    });
  });

  group('formatStopsSummary', () {
    test('extracts first segment and joins valid labels', () {
      final text = formatStopsSummary(
        isArabic: false,
        waypointLabels: const ['Olaya, Riyadh', 'King Fahd Rd, Riyadh'],
      );

      expect(text, 'Olaya • King Fahd Rd');
    });

    test('returns localized fallback when all labels are invalid', () {
      final en = formatStopsSummary(
        isArabic: false,
        waypointLabels: const ['N/A', '-', 'null'],
      );
      final ar = formatStopsSummary(
        isArabic: true,
        waypointLabels: const ['غير متوفر'],
      );

      expect(en, 'No stops');
      expect(ar, 'بدون محطات');
    });
  });
}
