import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';

void main() {
  group('RequestStatus parsing', () {
    test('requestStatusFromString parses all values', () {
      expect(requestStatusFromString('pending'), RequestStatus.pending);
      expect(requestStatusFromString('accepted'), RequestStatus.accepted);
      expect(requestStatusFromString('declined'), RequestStatus.declined);
      expect(requestStatusFromString('cancelled'), RequestStatus.cancelled);
      expect(requestStatusFromString('expired'), RequestStatus.expired);
      expect(requestStatusFromString('picked_up'), RequestStatus.pickedUp);
      expect(requestStatusFromString('dropped_off'), RequestStatus.droppedOff);
      expect(requestStatusFromString('completed'), RequestStatus.completed);
    });

    test('requestStatusFromString defaults to pending', () {
      expect(requestStatusFromString('xyz'), RequestStatus.pending);
    });

    test('requestStatusToString round trips', () {
      for (final s in RequestStatus.values) {
        expect(requestStatusFromString(requestStatusToString(s)), s);
      }
    });
  });

  group('Status transition validation', () {
    test('pending can transition to accepted/declined/cancelled/expired', () {
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.accepted),
        true,
      );
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.declined),
        true,
      );
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.cancelled),
        true,
      );
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.expired),
        true,
      );
    });

    test('pending cannot transition to completed or pickedUp', () {
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.completed),
        false,
      );
      expect(
        isTransitionAllowed(RequestStatus.pending, RequestStatus.pickedUp),
        false,
      );
    });

    test('accepted can transition to pickedUp or cancelled', () {
      expect(
        isTransitionAllowed(RequestStatus.accepted, RequestStatus.pickedUp),
        true,
      );
      expect(
        isTransitionAllowed(RequestStatus.accepted, RequestStatus.cancelled),
        true,
      );
    });

    test('pickedUp can only transition to droppedOff', () {
      expect(
        isTransitionAllowed(RequestStatus.pickedUp, RequestStatus.droppedOff),
        true,
      );
      expect(
        isTransitionAllowed(RequestStatus.pickedUp, RequestStatus.completed),
        false,
      );
    });

    test('droppedOff can only transition to completed', () {
      expect(
        isTransitionAllowed(
          RequestStatus.droppedOff,
          RequestStatus.completed,
        ),
        true,
      );
      expect(
        isTransitionAllowed(
          RequestStatus.droppedOff,
          RequestStatus.cancelled,
        ),
        false,
      );
    });

    test('terminal states allow no transitions', () {
      for (final terminal in [
        RequestStatus.declined,
        RequestStatus.cancelled,
        RequestStatus.expired,
        RequestStatus.completed,
      ]) {
        for (final target in RequestStatus.values) {
          expect(isTransitionAllowed(terminal, target), false);
        }
      }
    });

    test('validateTransition throws on invalid transition', () {
      expect(
        () =>
            validateTransition(RequestStatus.completed, RequestStatus.pending),
        throwsA(isA<InvalidStatusTransitionException>()),
      );
    });

    test('InvalidStatusTransitionException toString is readable', () {
      const e = InvalidStatusTransitionException(
        RequestStatus.pending,
        RequestStatus.completed,
      );
      expect(e.toString(), contains('pending'));
      expect(e.toString(), contains('completed'));
    });
  });

  group('TripRequest', () {
    const ts = '2026-02-16T08:00:00.000Z';
    final baseJson = <String, dynamic>{
      'id': 'r1',
      'trip_id': 't1',
      'passenger_id': 'p1',
      'driver_id': 'd1',
      'status': 'accepted',
      'created_at': ts,
      'flex_offer_sar': 15.0,
      'flex_note': 'I can split fuel costs',
      'rating_given': 5,
      'rating_received': 4,
    };

    test('fromJson parses all fields', () {
      final r = TripRequest.fromJson(baseJson);
      expect(r.id, 'r1');
      expect(r.tripId, 't1');
      expect(r.passengerId, 'p1');
      expect(r.driverId, 'd1');
      expect(r.status, RequestStatus.accepted);
      expect(r.flexOfferSar, 15.0);
      expect(r.flexNote, 'I can split fuel costs');
      expect(r.ratingGiven, 5);
      expect(r.ratingReceived, 4);
    });

    test('fromJson defaults to pending when status missing', () {
      final r = TripRequest.fromJson({
        'id': 'r2',
        'trip_id': 't2',
        'passenger_id': 'p2',
        'created_at': ts,
      });
      expect(r.status, RequestStatus.pending);
      expect(r.driverId, isNull);
      expect(r.flexOfferSar, isNull);
    });

    test('hasFlexOffer returns true when positive SAR amount', () {
      final r = TripRequest.fromJson(baseJson);
      expect(r.hasFlexOffer, true);
    });

    test('hasFlexOffer returns false when null', () {
      final r = TripRequest.fromJson({
        ...baseJson,
        'flex_offer_sar': null,
      });
      expect(r.hasFlexOffer, false);
    });

    test('hasFlexOffer returns false when zero', () {
      final r = TripRequest.fromJson({
        ...baseJson,
        'flex_offer_sar': 0.0,
      });
      expect(r.hasFlexOffer, false);
    });
  });
}
