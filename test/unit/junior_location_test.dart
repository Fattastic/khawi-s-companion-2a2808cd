import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/junior_location.dart';

void main() {
  group('JuniorLocation', () {
    const ts = '2026-03-01T07:45:00.000Z';

    test('fromJson parses all fields', () {
      final jl = JuniorLocation.fromJson({
        'id': 'jl1',
        'run_id': 'jr1',
        'user_id': 'd1',
        'lat': 24.7136,
        'lng': 46.6753,
        'heading': 180.5,
        'speed': 35.2,
        'accuracy': 10.0,
        'created_at': ts,
      });
      expect(jl.id, 'jl1');
      expect(jl.runId, 'jr1');
      expect(jl.userId, 'd1');
      expect(jl.lat, 24.7136);
      expect(jl.lng, 46.6753);
      expect(jl.heading, 180.5);
      expect(jl.speed, 35.2);
      expect(jl.accuracy, 10.0);
      expect(jl.createdAt, DateTime.utc(2026, 3, 1, 7, 45));
    });

    test('fromJson defaults heading/speed/accuracy to 0 when missing', () {
      final jl = JuniorLocation.fromJson({
        'id': 'jl2',
        'run_id': 'jr2',
        'user_id': 'd2',
        'lat': 24.0,
        'lng': 46.0,
        'created_at': ts,
      });
      expect(jl.heading, 0.0);
      expect(jl.speed, 0.0);
      expect(jl.accuracy, 0.0);
    });
  });
}
