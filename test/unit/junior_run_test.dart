import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/junior_run.dart';

void main() {
  group('JuniorRun', () {
    const ts = '2026-03-01T07:30:00.000Z';

    final fullJson = <String, dynamic>{
      'id': 'jr1',
      'kid_id': 'k1',
      'parent_id': 'p1',
      'assigned_driver_id': 'd1',
      'status': 'picked_up',
      'pickup_lat': 24.7136,
      'pickup_lng': 46.6753,
      'dropoff_lat': 24.7236,
      'dropoff_lng': 46.6853,
      'pickup_time': ts,
      'trip_id': 't1',
    };

    test('fromJson parses all fields', () {
      final jr = JuniorRun.fromJson(fullJson);
      expect(jr.id, 'jr1');
      expect(jr.kidId, 'k1');
      expect(jr.parentId, 'p1');
      expect(jr.assignedDriverId, 'd1');
      expect(jr.status, 'picked_up');
      expect(jr.pickupLat, 24.7136);
      expect(jr.pickupLng, 46.6753);
      expect(jr.dropoffLat, 24.7236);
      expect(jr.dropoffLng, 46.6853);
      expect(jr.pickupTime, DateTime.utc(2026, 3, 1, 7, 30));
      expect(jr.tripId, 't1');
    });

    test('fromJson handles nullable fields', () {
      final jr = JuniorRun.fromJson({
        'id': 'jr2',
        'kid_id': 'k2',
        'parent_id': 'p2',
        'status': 'planned',
        'pickup_lat': 0.0,
        'pickup_lng': 0.0,
        'dropoff_lat': 0.0,
        'dropoff_lng': 0.0,
        'pickup_time': ts,
      });
      expect(jr.assignedDriverId, isNull);
      expect(jr.tripId, isNull);
      expect(jr.status, 'planned');
    });

    test('all status values parse correctly', () {
      const statuses = [
        'planned',
        'driver_assigned',
        'picked_up',
        'arrived',
        'completed',
        'cancelled',
      ];
      for (final s in statuses) {
        final jr = JuniorRun.fromJson({...fullJson, 'status': s});
        expect(jr.status, s);
      }
    });
  });
}
