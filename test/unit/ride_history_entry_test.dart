import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';

void main() {
  group('RideHistoryEntry', () {
    final baseJson = <String, dynamic>{
      'trip_id': 't1',
      'request_id': 'r1',
      'origin_label': 'KFUPM Gate 1',
      'dest_label': 'Al Rashid Mall',
      'origin_lat': 26.307,
      'origin_lng': 50.144,
      'dest_lat': 26.420,
      'dest_lng': 50.095,
      'waypoint_labels': ['Stop A', 'Stop B'],
      'departure_time': '2026-02-16T08:30:00.000Z',
      'completed_at': '2026-02-16T09:00:00.000Z',
      'counterpart_name': 'Ahmed',
      'counterpart_avatar_url': 'https://img.co/ahmed.jpg',
      'rating_given': 5,
      'rating_received': 4,
      'status': 'completed',
      'distance_km': 15.3,
      'co2_saved_kg': 2.1,
      'xp_earned': 25,
    };

    test('fromJson parses all fields', () {
      final e = RideHistoryEntry.fromJson(baseJson);
      expect(e.tripId, 't1');
      expect(e.requestId, 'r1');
      expect(e.originLabel, 'KFUPM Gate 1');
      expect(e.destLabel, 'Al Rashid Mall');
      expect(e.waypointLabels, ['Stop A', 'Stop B']);
      expect(e.counterpartName, 'Ahmed');
      expect(e.ratingGiven, 5);
      expect(e.ratingReceived, 4);
      expect(e.distanceKm, 15.3);
      expect(e.co2SavedKg, 2.1);
      expect(e.xpEarned, 25);
      expect(e.completedAt, isNotNull);
    });

    test('fromJson handles minimal data with defaults', () {
      final e = RideHistoryEntry.fromJson({
        'trip_id': 't2',
        'request_id': 'r2',
        'origin_lat': 24.72,
        'origin_lng': 46.63,
        'dest_lat': 24.70,
        'dest_lng': 46.60,
        'departure_time': '2026-02-16T08:00:00.000Z',
      });
      expect(e.status, 'completed'); // default
      expect(e.waypointLabels, isEmpty);
      expect(e.originLabel, isNull);
      expect(e.ratingGiven, isNull);
      expect(e.completedAt, isNull);
    });

    test('canRate is true when completed and no rating given', () {
      final e = RideHistoryEntry.fromJson({
        ...baseJson,
        'rating_given': null,
        'status': 'completed',
      });
      expect(e.canRate, true);
    });

    test('canRate is false when already rated', () {
      final e = RideHistoryEntry.fromJson(baseJson);
      expect(e.canRate, false); // rating_given = 5
    });

    test('canRate is false when not completed', () {
      final e = RideHistoryEntry.fromJson({
        ...baseJson,
        'rating_given': null,
        'status': 'cancelled',
      });
      expect(e.canRate, false);
    });

    test('isCompleted returns true for completed status', () {
      final e = RideHistoryEntry.fromJson(baseJson);
      expect(e.isCompleted, true);
    });

    test('isCompleted returns false for other statuses', () {
      final e = RideHistoryEntry.fromJson({...baseJson, 'status': 'cancelled'});
      expect(e.isCompleted, false);
    });

    test('formattedDate returns D/M/Y', () {
      final e = RideHistoryEntry.fromJson(baseJson);
      expect(e.formattedDate, '16/2/2026');
    });

    test('formattedTime returns HH:MM padded', () {
      final e = RideHistoryEntry.fromJson(baseJson);
      // 08:30 UTC — the time depends on local timezone but at minimum
      // should contain two digits for hours and minutes
      expect(e.formattedTime, matches(RegExp(r'^\d{2}:\d{2}$')));
    });
  });
}
