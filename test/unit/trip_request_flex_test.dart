import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/requests/domain/trip_request.dart';

void main() {
  group('TripRequest Khawi Flex fields', () {
    test('fromJson maps flex fields when present', () {
      final req = TripRequest.fromJson({
        'id': 'r1',
        'trip_id': 't1',
        'passenger_id': 'p1',
        'status': 'pending',
        'created_at': DateTime(2026, 2, 16).toIso8601String(),
        'flex_offer_sar': 18.5,
        'flex_note': 'Can meet near gate 2',
      });

      expect(req.flexOfferSar, 18.5);
      expect(req.flexNote, 'Can meet near gate 2');
      expect(req.hasFlexOffer, isTrue);
    });

    test('hasFlexOffer false for null/zero', () {
      final req = TripRequest.fromJson({
        'id': 'r2',
        'trip_id': 't2',
        'passenger_id': 'p2',
        'status': 'pending',
        'created_at': DateTime(2026, 2, 16).toIso8601String(),
        'flex_offer_sar': null,
      });

      expect(req.flexOfferSar, isNull);
      expect(req.hasFlexOffer, isFalse);
    });
  });
}
