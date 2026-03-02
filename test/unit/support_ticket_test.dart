import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/support/domain/support_ticket.dart';

void main() {
  group('SupportTicket', () {
    test('fromJson parses all fields', () {
      final t = SupportTicket.fromJson({
        'id': 'st1',
        'subject': 'Cannot find rides',
        'body': 'No rides showing in my area',
        'status': 'open',
        'created_at': '2026-02-16T10:00:00.000Z',
      });
      expect(t.id, 'st1');
      expect(t.subject, 'Cannot find rides');
      expect(t.body, 'No rides showing in my area');
      expect(t.status, 'open');
    });

    test('fromJson uses defaults for missing optional fields', () {
      final t = SupportTicket.fromJson({
        'id': 'st2',
        'created_at': '2026-02-16T10:00:00.000Z',
      });
      expect(t.subject, 'No Subject');
      expect(t.body, '');
      expect(t.status, 'open');
    });
  });
}
