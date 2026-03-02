import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

Map<String, dynamic> _tripJson({String id = 't1'}) => {
      'id': id,
      'driver_id': 'd1',
      'status': 'active',
      'origin_lat': 24.7,
      'origin_lng': 46.6,
      'dest_lat': 24.8,
      'dest_lng': 46.7,
      'departure_time': '2026-01-01T00:00:00.000Z',
    };

void main() {
  group('Match', () {
    test('copyWith overrides selected fields', () {
      final trip = Trip.fromJson(_tripJson());
      final m = Match(
        trip: trip,
        score: 80,
        explanationTags: ['same_neighborhood'],
        acceptProbability: 0.75,
        etaMinutes: 5,
      );
      final m2 = m.copyWith(score: 95, etaMinutes: 3);
      expect(m2.score, 95);
      expect(m2.etaMinutes, 3);
      expect(m2.trip, same(trip));
      expect(m2.acceptProbability, 0.75);
      expect(m2.explanationTags, ['same_neighborhood']);
    });

    test('copyWith with no args returns equal object', () {
      final trip = Trip.fromJson(_tripJson(id: 't2'));
      final m = Match(
        trip: trip,
        score: 50,
        explanationTags: [],
        acceptProbability: 0.5,
      );
      final m2 = m.copyWith();
      expect(m2.score, 50);
      expect(m2.etaMinutes, isNull);
    });
  });

  group('MatchRequest', () {
    test('maxResults defaults to 20', () {
      const mr = MatchRequest(
        originLat: 24.7,
        originLng: 46.6,
        destLat: 24.8,
        destLng: 46.7,
      );
      expect(mr.maxResults, 20);
      expect(mr.departureTime, isNull);
      expect(mr.womenOnly, isNull);
    });

    test('custom maxResults is respected', () {
      const mr = MatchRequest(
        originLat: 0,
        originLng: 0,
        destLat: 1,
        destLng: 1,
        maxResults: 5,
        womenOnly: true,
      );
      expect(mr.maxResults, 5);
      expect(mr.womenOnly, true);
    });
  });

  group('BundleStop', () {
    test('fromJson parses all fields', () {
      final bs = BundleStop.fromJson({
        'type': 'dropoff',
        'label': 'KFUPM Gate 1',
        'lat': 26.31,
        'lng': 50.14,
        'passenger_id': 'p1',
      });
      expect(bs.type, 'dropoff');
      expect(bs.label, 'KFUPM Gate 1');
      expect(bs.lat, 26.31);
      expect(bs.lng, 50.14);
      expect(bs.passengerId, 'p1');
    });

    test('fromJson uses defaults', () {
      final bs = BundleStop.fromJson(<String, dynamic>{});
      expect(bs.type, 'pickup');
      expect(bs.label, 'Stop');
      expect(bs.lat, isNull);
      expect(bs.lng, isNull);
      expect(bs.passengerId, isNull);
    });
  });

  group('MatchingException', () {
    test('toString includes message', () {
      const ex = MatchingException('No matches found');
      expect(ex.toString(), contains('No matches found'));
    });
  });
}
