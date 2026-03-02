import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/realtime/domain/trip_location.dart';

void main() {
  group('TripLocation', () {
    const ts = '2026-04-10T14:30:00.000Z';

    test('fromJson parses all fields', () {
      final tl = TripLocation.fromJson({
        'id': 'tl1',
        'trip_id': 't1',
        'user_id': 'u1',
        'lat': 24.7136,
        'lng': 46.6753,
        'heading': 90.0,
        'speed': 60.5,
        'created_at': ts,
      });
      expect(tl.id, 'tl1');
      expect(tl.tripId, 't1');
      expect(tl.userId, 'u1');
      expect(tl.lat, 24.7136);
      expect(tl.lng, 46.6753);
      expect(tl.heading, 90.0);
      expect(tl.speed, 60.5);
      expect(tl.createdAt, DateTime.utc(2026, 4, 10, 14, 30));
    });
  });
}
