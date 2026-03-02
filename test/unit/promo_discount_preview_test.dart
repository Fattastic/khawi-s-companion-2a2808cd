import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/promo_codes/domain/promo_discount_preview.dart';

void main() {
  group('computePromoDiscount', () {
    test('calculates percent discounts', () {
      final discount = computePromoDiscount(
        discountType: 'percent',
        discountValue: 10,
        fareSar: 80,
      );

      expect(discount, 8);
    });

    test('caps discount by max value', () {
      final discount = computePromoDiscount(
        discountType: 'percent',
        discountValue: 50,
        fareSar: 120,
        maxDiscountSar: 25,
      );

      expect(discount, 25);
    });

    test('never exceeds fare amount', () {
      final discount = computePromoDiscount(
        discountType: 'fixed',
        discountValue: 20,
        fareSar: 10,
      );

      expect(discount, 10);
    });
  });
}
