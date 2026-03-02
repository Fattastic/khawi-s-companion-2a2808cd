import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/notifications/domain/app_notification.dart';

void main() {
  group('AppNotification', () {
    const ts = '2026-02-16T10:00:00.000Z';
    final fullJson = <String, dynamic>{
      'id': 'n1',
      'title': 'New ride match!',
      'body': 'Ahmed matched your trip to KFUPM',
      'type': 'success',
      'created_at': ts,
      'is_read': true,
    };

    test('fromJson parses all fields', () {
      final n = AppNotification.fromJson(fullJson);
      expect(n.id, 'n1');
      expect(n.title, 'New ride match!');
      expect(n.body, 'Ahmed matched your trip to KFUPM');
      expect(n.type, 'success');
      expect(n.isRead, true);
      expect(n.createdAt, DateTime.utc(2026, 2, 16, 10));
    });

    test('isRead defaults to false when missing', () {
      final n = AppNotification.fromJson({
        'id': 'n2',
        'title': 'Info',
        'body': 'Update available',
        'type': 'info',
        'created_at': ts,
      });
      expect(n.isRead, false);
    });

    test('toJson round-trips correctly', () {
      final n = AppNotification.fromJson(fullJson);
      final j = n.toJson();
      expect(j['id'], 'n1');
      expect(j['title'], 'New ride match!');
      expect(j['type'], 'success');
      expect(j['is_read'], true);

      // Round-trip
      final n2 = AppNotification.fromJson(j);
      expect(n2.id, n.id);
      expect(n2.title, n.title);
      expect(n2.type, n.type);
      expect(n2.isRead, n.isRead);
    });

    test('supports all notification types', () {
      for (final t in ['info', 'success', 'warning', 'error']) {
        final n = AppNotification.fromJson({...fullJson, 'type': t});
        expect(n.type, t);
      }
    });
  });
}
