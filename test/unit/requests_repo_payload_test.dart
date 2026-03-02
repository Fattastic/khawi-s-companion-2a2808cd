import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/requests/data/requests_repo.dart';

void main() {
  group('buildSendJoinRequestParams', () {
    test('trims trip id and optional text fields', () {
      final params = buildSendJoinRequestParams(
        tripId: '  trip_123  ',
        pickupLabel: '  Main Gate  ',
        flexNote: '  Please call  ',
      );

      expect(params['p_trip_id'], 'trip_123');
      expect(params['p_pickup_label'], 'Main Gate');
      expect(params['p_flex_note'], 'Please call');
    });

    test('normalizes invalid numeric values to null', () {
      final params = buildSendJoinRequestParams(
        tripId: 'trip_123',
        pickupLat: double.nan,
        pickupLng: double.infinity,
        flexOfferSar: 0,
      );

      expect(params['p_pickup_lat'], isNull);
      expect(params['p_pickup_lng'], isNull);
      expect(params['p_flex_offer_sar'], isNull);
    });

    test('throws when trip id is empty after trim', () {
      expect(
        () => buildSendJoinRequestParams(tripId: '   '),
        throwsArgumentError,
      );
    });
  });
}
