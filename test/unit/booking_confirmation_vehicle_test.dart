import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/presentation/booking_confirmation_screen.dart';

void main() {
  group('formatVehicleSummary', () {
    String renderAndGet({
      required bool isArabic,
      String? model,
      String? plate,
    }) {
      return formatVehicleSummary(
        isArabic: isArabic,
        vehicleModel: model,
        vehiclePlateNumber: plate,
      );
    }

    test('returns model and plate when both are available', () {
      final text = renderAndGet(
        isArabic: false,
        model: 'Toyota Camry 2023',
        plate: 'ABC 1234',
      );

      expect(text, 'Toyota Camry 2023 • ABC 1234');
    });

    test('returns localized fallback when model and plate are missing', () {
      final en = renderAndGet(isArabic: false);
      final ar = renderAndGet(isArabic: true);

      expect(en, 'Not available');
      expect(ar, 'غير متوفر');
    });

    test('returns non-empty single value when only one field exists', () {
      final modelOnly = renderAndGet(
        isArabic: false,
        model: 'Kia K5',
      );
      final plateOnly = renderAndGet(
        isArabic: false,
        plate: 'XYZ 9988',
      );

      expect(modelOnly, 'Kia K5');
      expect(plateOnly, 'XYZ 9988');
    });

    test('normalizes placeholder values to localized fallback', () {
      final en = renderAndGet(
        isArabic: false,
        model: 'N/A',
        plate: '-',
      );
      final ar = renderAndGet(
        isArabic: true,
        model: 'null',
        plate: 'غير متوفر',
      );

      expect(en, 'Not available');
      expect(ar, 'غير متوفر');
    });

    test('prefers valid value when paired field is placeholder', () {
      final text = renderAndGet(
        isArabic: false,
        model: 'Toyota Yaris',
        plate: 'N/A',
      );

      expect(text, 'Toyota Yaris');
    });
  });
}
