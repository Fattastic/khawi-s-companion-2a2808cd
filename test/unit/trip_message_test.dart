import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/realtime/domain/trip_message.dart';

void main() {
  group('TripMessage', () {
    const ts = '2026-04-10T14:35:00.000Z';

    test('fromJson parses all fields', () {
      final tm = TripMessage.fromJson({
        'id': 'msg1',
        'trip_id': 't1',
        'sender_id': 'u1',
        'body': 'I am at the gate',
        'created_at': ts,
      });
      expect(tm.id, 'msg1');
      expect(tm.tripId, 't1');
      expect(tm.senderId, 'u1');
      expect(tm.body, 'I am at the gate');
      expect(tm.createdAt, DateTime.utc(2026, 4, 10, 14, 35));
    });

    test('toJson round-trips', () {
      final tm = TripMessage.fromJson({
        'id': 'msg2',
        'trip_id': 't2',
        'sender_id': 'u2',
        'body': 'On my way',
        'created_at': ts,
      });
      final j = tm.toJson();
      expect(j['id'], 'msg2');
      expect(j['trip_id'], 't2');
      expect(j['body'], 'On my way');

      final tm2 = TripMessage.fromJson(j);
      expect(tm2.id, tm.id);
      expect(tm2.body, tm.body);
    });
  });
}
