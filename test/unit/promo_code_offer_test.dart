import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/promo_codes/domain/promo_code_offer.dart';

void main() {
  group('PromoCodeOffer', () {
    final fullJson = <String, dynamic>{
      'user_promo_id': 'up1',
      'code': 'SUMMER25',
      'title': '25% Off Summer Rides',
      'discount_type': 'percentage',
      'discount_value': 25.0,
      'max_discount_sar': 50.0,
      'min_fare_sar': 10.0,
      'expires_at': '2026-08-31T23:59:59.000Z',
      'claimed_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields', () {
      final p = PromoCodeOffer.fromJson(fullJson);
      expect(p.userPromoId, 'up1');
      expect(p.code, 'SUMMER25');
      expect(p.title, '25% Off Summer Rides');
      expect(p.discountType, 'percentage');
      expect(p.discountValue, 25.0);
      expect(p.maxDiscountSar, 50.0);
      expect(p.minFareSar, 10.0);
      expect(p.expiresAt, isNotNull);
      expect(p.claimedAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final p = PromoCodeOffer.fromJson({
        'user_promo_id': 'up2',
        'code': 'TEST',
        'title': 'Test',
        'discount_type': 'flat',
        'discount_value': 10,
      });
      expect(p.maxDiscountSar, isNull);
      expect(p.minFareSar, 0.0);
      expect(p.expiresAt, isNull);
      expect(p.claimedAt, isNull);
    });

    test('fromJson handles all-null gracefully', () {
      final p = PromoCodeOffer.fromJson({});
      expect(p.userPromoId, '');
      expect(p.code, '');
      expect(p.discountValue, 0.0);
    });

    test('_parseDate handles invalid strings', () {
      final p = PromoCodeOffer.fromJson({
        ...fullJson,
        'expires_at': 'not-a-date',
      });
      expect(p.expiresAt, isNull);
    });
  });
}
