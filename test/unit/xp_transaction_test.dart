import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/xp_ledger/domain/xp_transaction.dart';

void main() {
  group('XpTransaction', () {
    const ts = '2026-02-16T10:00:00.000Z';

    test('fromJson parses all fields', () {
      final x = XpTransaction.fromJson({
        'id': 'xp1',
        'user_id': 'u1',
        'title': 'Trip Completed',
        'amount': '+25',
        'type': 'credit',
        'created_at': ts,
      });
      expect(x.id, 'xp1');
      expect(x.userId, 'u1');
      expect(x.title, 'Trip Completed');
      expect(x.amount, '+25');
      expect(x.type, 'credit');
    });

    test('toJson round-trips', () {
      final x = XpTransaction.fromJson({
        'id': 'xp2',
        'user_id': 'u2',
        'title': 'Reward Redeemed',
        'amount': '-100',
        'type': 'debit',
        'created_at': ts,
      });
      final j = x.toJson();
      expect(j['id'], 'xp2');
      expect(j['user_id'], 'u2');
      expect(j['amount'], '-100');
      expect(j['type'], 'debit');

      final x2 = XpTransaction.fromJson(j);
      expect(x2.id, x.id);
      expect(x2.amount, x.amount);
    });
  });
}
