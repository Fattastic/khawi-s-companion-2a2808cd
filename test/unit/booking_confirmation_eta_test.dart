import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/presentation/booking_confirmation_screen.dart';

void main() {
  group('formatEtaSummary', () {
    test('returns english minutes when eta is positive', () {
      final text = formatEtaSummary(isArabic: false, etaMinutes: 12);
      expect(text, '12 min');
    });

    test('returns arabic minutes when eta is positive', () {
      final text = formatEtaSummary(isArabic: true, etaMinutes: 7);
      expect(text, '7 د');
    });

    test('returns localized calculating fallback for null or non-positive eta',
        () {
      expect(
        formatEtaSummary(isArabic: false, etaMinutes: null),
        'Calculating...',
      );
      expect(
        formatEtaSummary(isArabic: false, etaMinutes: 0),
        'Calculating...',
      );
      expect(
        formatEtaSummary(isArabic: true, etaMinutes: -1),
        'جاري الحساب...',
      );
    });
  });
}
