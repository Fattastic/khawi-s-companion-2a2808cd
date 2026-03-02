import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';

void main() {
  group('Kid', () {
    test('fromJson parses all fields', () {
      final k = Kid.fromJson({
        'id': 'k1',
        'parent_id': 'p1',
        'name': 'Faris',
        'avatar_url': 'https://img.co/faris.jpg',
        'school_name': 'KFUPM School',
        'notes': 'Allergic to peanuts',
        'age': 8,
      });
      expect(k.id, 'k1');
      expect(k.parentId, 'p1');
      expect(k.name, 'Faris');
      expect(k.avatarUrl, isNotNull);
      expect(k.schoolName, 'KFUPM School');
      expect(k.age, 8);
    });

    test('fromJson defaults name to empty string when null', () {
      final k = Kid.fromJson({
        'id': 'k2',
        'parent_id': 'p1',
        'name': null,
      });
      expect(k.name, '');
    });

    test('fromJson handles missing optional fields', () {
      final k = Kid.fromJson({
        'id': 'k3',
        'parent_id': 'p1',
        'name': 'Sara',
      });
      expect(k.avatarUrl, isNull);
      expect(k.schoolName, isNull);
      expect(k.notes, isNull);
      expect(k.age, isNull);
    });
  });

  group('JuniorRun', () {
    test('fromJson parses all fields', () {
      final r = JuniorRun.fromJson({
        'id': 'r1',
        'kid_id': 'k1',
        'parent_id': 'p1',
        'assigned_driver_id': 'd1',
        'trip_id': 't1',
        'status': 'in_progress',
        'pickup_lat': 24.72,
        'pickup_lng': 46.63,
        'dropoff_lat': 24.70,
        'dropoff_lng': 46.60,
        'pickup_time': '2026-02-16T07:00:00.000Z',
      });
      expect(r.id, 'r1');
      expect(r.assignedDriverId, 'd1');
      expect(r.status, 'in_progress');
      expect(r.pickupLat, 24.72);
      expect(r.dropoffLng, 46.60);
    });

    test('fromJson defaults status to planned', () {
      final r = JuniorRun.fromJson({
        'id': 'r2',
        'kid_id': 'k1',
        'parent_id': 'p1',
        'pickup_lat': 24.72,
        'pickup_lng': 46.63,
        'dropoff_lat': 24.70,
        'dropoff_lng': 46.60,
        'pickup_time': '2026-02-16T07:00:00.000Z',
      });
      expect(r.status, 'planned');
      expect(r.assignedDriverId, isNull);
      expect(r.tripId, isNull);
    });
  });

  group('JuniorRunEvent', () {
    test('fromJson parses all fields', () {
      final e = JuniorRunEvent.fromJson({
        'id': 'je1',
        'run_id': 'r1',
        'actor_id': 'd1',
        'actor_role': 'driver',
        'event_type': 'pickup',
        'prev_status': 'en_route',
        'new_status': 'picked_up',
        'lat': 24.72,
        'lng': 46.63,
        'meta': <String, dynamic>{'note': 'arrived on time'},
        'created_at': '2026-02-16T07:05:00.000Z',
      });
      expect(e.eventType, 'pickup');
      expect(e.prevStatus, 'en_route');
      expect(e.newStatus, 'picked_up');
      expect(e.lat, 24.72);
      expect(e.meta?['note'], 'arrived on time');
    });

    test('fromJson handles null optional fields', () {
      final e = JuniorRunEvent.fromJson({
        'id': 'je2',
        'run_id': 'r1',
        'actor_id': 'p1',
        'actor_role': 'parent',
        'event_type': 'sos',
        'created_at': '2026-02-16T07:10:00.000Z',
      });
      expect(e.prevStatus, isNull);
      expect(e.lat, isNull);
      expect(e.meta, isNull);
    });
  });

  group('SosEvent', () {
    test('fromJson parses all fields', () {
      final s = SosEvent.fromJson({
        'id': 'sos1',
        'run_id': 'r1',
        'trip_id': 't1',
        'triggered_by': 'parent',
        'parent_id': 'p1',
        'driver_id': 'd1',
        'kind': 'emergency',
        'status': 'active',
        'severity': 3,
        'lat': 24.72,
        'lng': 46.63,
        'message': 'Help!',
        'meta': <String, dynamic>{'battery': 45},
        'created_at': '2026-02-16T07:15:00.000Z',
      });
      expect(s.kind, 'emergency');
      expect(s.severity, 3);
      expect(s.message, 'Help!');
      expect(s.driverId, 'd1');
    });

    test('fromJson handles missing optional fields', () {
      final s = SosEvent.fromJson({
        'id': 'sos2',
        'triggered_by': 'parent',
        'kind': 'panic',
        'status': 'resolved',
        'severity': 1,
        'lat': 24.72,
        'lng': 46.63,
        'created_at': '2026-02-16T07:20:00.000Z',
      });
      expect(s.runId, isNull);
      expect(s.tripId, isNull);
      expect(s.message, isNull);
    });
  });
}
