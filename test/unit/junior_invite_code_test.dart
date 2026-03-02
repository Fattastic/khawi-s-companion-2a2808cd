import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/junior_invite_code.dart';

void main() {
  group('JuniorInviteCode', () {
    test('fromJson parses fields and normalizes code', () {
      final invite = JuniorInviteCode.fromJson({
        'id': 'inv_1',
        'code': 'ab12cd',
        'parent_id': 'parent_1',
        'is_used': false,
        'expires_at': '2030-01-01T00:00:00Z',
        'created_at': '2026-02-21T00:00:00Z',
        'invited_driver_name': 'Driver Name',
        'invited_driver_phone': '+966500000000',
        'invited_driver_relation': 'uncle',
      });

      expect(invite.id, 'inv_1');
      expect(invite.code, 'AB12CD');
      expect(invite.parentId, 'parent_1');
      expect(invite.isUsed, false);
      expect(invite.invitedDriverName, 'Driver Name');
      expect(invite.invitedDriverPhone, '+966500000000');
      expect(invite.invitedDriverRelation, 'uncle');
    });

    test('isPending true when invite is unused and unexpired', () {
      final invite = JuniorInviteCode(
        id: 'inv_2',
        code: 'ZX9876',
        parentId: 'parent_1',
        isUsed: false,
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        createdAt: DateTime.now().toUtc(),
      );

      expect(invite.isPending, true);
      expect(invite.isExpired, false);
    });

    test('isPending false when invite is used', () {
      final invite = JuniorInviteCode(
        id: 'inv_3',
        code: 'ZX9876',
        parentId: 'parent_1',
        isUsed: true,
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        createdAt: DateTime.now().toUtc(),
      );

      expect(invite.isPending, false);
    });
  });
}
