import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

void main() {
  group('TripStatus', () {
    test('tripStatusFromString parses all values', () {
      expect(tripStatusFromString('planned'), TripStatus.planned);
      expect(tripStatusFromString('active'), TripStatus.active);
      expect(tripStatusFromString('completed'), TripStatus.completed);
      expect(tripStatusFromString('cancelled'), TripStatus.cancelled);
    });

    test('tripStatusFromString defaults to planned', () {
      expect(tripStatusFromString('unknown'), TripStatus.planned);
      expect(tripStatusFromString(''), TripStatus.planned);
    });

    test('tripStatusToString round trips', () {
      for (final s in TripStatus.values) {
        expect(tripStatusFromString(tripStatusToString(s)), s);
      }
    });
  });

  group('TripWaypoint', () {
    test('fromJson parses lat/lng/label', () {
      final w = TripWaypoint.fromJson({
        'lat': 26.307,
        'lng': 50.144,
        'label': 'KFUPM Gate 1',
      });
      expect(w.lat, 26.307);
      expect(w.lng, 50.144);
      expect(w.label, 'KFUPM Gate 1');
    });

    test('fromJson defaults label to Stop', () {
      final w = TripWaypoint.fromJson({'lat': 24.0, 'lng': 46.0});
      expect(w.label, 'Stop');
    });

    test('toJson round-trips', () {
      final w = TripWaypoint.fromJson({
        'lat': 26.0,
        'lng': 50.0,
        'label': 'A',
      });
      final j = w.toJson();
      expect(j['lat'], 26.0);
      expect(j['lng'], 50.0);
      expect(j['label'], 'A');
    });
  });

  group('Trip', () {
    final baseJson = <String, dynamic>{
      'id': 't1',
      'driver_id': 'd1',
      'origin_lat': 26.307,
      'origin_lng': 50.144,
      'dest_lat': 26.420,
      'dest_lng': 50.095,
      'origin_label': 'KFUPM',
      'dest_label': 'Al Rashid Mall',
      'departure_time': '2026-02-16T08:00:00.000Z',
      'seats_total': 4,
      'seats_available': 2,
      'women_only': true,
      'is_kids_ride': false,
      'is_recurring': false,
      'tags': ['campus', 'morning'],
      'status': 'active',
      'match_score': 85,
      'accept_prob': 0.92,
      'explanation_tags': ['route_overlap', 'time_match'],
      'eta_minutes': 15,
      'distance_km': 12.5,
      'co2_saved_kg': 1.8,
    };

    test('fromJson parses all fields', () {
      final t = Trip.fromJson(baseJson);
      expect(t.id, 't1');
      expect(t.driverId, 'd1');
      expect(t.originLat, 26.307);
      expect(t.originLabel, 'KFUPM');
      expect(t.destLabel, 'Al Rashid Mall');
      expect(t.seatsTotal, 4);
      expect(t.seatsAvailable, 2);
      expect(t.womenOnly, true);
      expect(t.isKidsRide, false);
      expect(t.tags, ['campus', 'morning']);
      expect(t.status, TripStatus.active);
      expect(t.matchScore, 85);
      expect(t.acceptProb, 0.92);
      expect(t.matchTags, ['route_overlap', 'time_match']);
      expect(t.etaMinutes, 15);
      expect(t.distanceKm, 12.5);
      expect(t.co2SavedKg, 1.8);
    });

    test('fromJson uses defaults for optional fields', () {
      final t = Trip.fromJson({
        'id': 't2',
        'driver_id': 'd2',
        'origin_lat': 24.0,
        'origin_lng': 46.0,
        'dest_lat': 24.1,
        'dest_lng': 46.1,
        'departure_time': '2026-02-16T08:00:00.000Z',
      });
      expect(t.seatsTotal, 0);
      expect(t.seatsAvailable, 0);
      expect(t.womenOnly, false);
      expect(t.isKidsRide, false);
      expect(t.isRecurring, false);
      expect(t.tags, isEmpty);
      expect(t.status, TripStatus.planned);
      expect(t.waypoints, isEmpty);
      expect(t.matchScore, isNull);
    });

    test('fromJson parses waypoints list', () {
      final t = Trip.fromJson({
        ...baseJson,
        'waypoints': [
          {'lat': 26.35, 'lng': 50.12, 'label': 'Stop A'},
          {'lat': 26.38, 'lng': 50.10, 'label': 'Stop B'},
        ],
      });
      expect(t.waypoints.length, 2);
      expect(t.waypoints[0].label, 'Stop A');
    });

    test('fromJson reads waypoints from schedule_json fallback', () {
      final t = Trip.fromJson({
        ...baseJson,
        'waypoints': null,
        'schedule_json': {
          'waypoints': [
            {'lat': 26.35, 'lng': 50.12, 'label': 'Schedule Stop'},
          ],
        },
      });
      expect(t.waypoints.length, 1);
      expect(t.waypoints[0].label, 'Schedule Stop');
    });

    test('toJson includes all fields', () {
      final t = Trip.fromJson(baseJson);
      final j = t.toJson();
      expect(j['id'], 't1');
      expect(j['driver_id'], 'd1');
      expect(j['status'], 'active');
      expect(j['match_score'], 85);
      expect(j['explanation_tags'], ['route_overlap', 'time_match']);
    });

    test('toDbJson excludes computed fields', () {
      final t = Trip.fromJson(baseJson);
      final j = t.toDbJson();
      expect(j['id'], 't1'); // id included when non-empty
      expect(j['driver_id'], 'd1');
      expect(j.containsKey('match_score'), false);
      expect(j.containsKey('accept_prob'), false);
    });

    test('copyWith overrides selected fields', () {
      final t = Trip.fromJson(baseJson);
      final t2 = t.copyWith(status: TripStatus.completed, seatsAvailable: 0);
      expect(t2.status, TripStatus.completed);
      expect(t2.seatsAvailable, 0);
      expect(t2.id, t.id); // unchanged
      expect(t2.driverId, t.driverId);
    });
  });
}
