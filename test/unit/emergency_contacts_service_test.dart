import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khawi_flutter/services/emergency_contacts_service.dart';

void main() {
  group('EmergencyContactsService', () {
    late EmergencyContactsService service;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      service = EmergencyContactsService();
    });

    test('adds a contact and persists normalized values', () async {
      await service.addContact(
        const EmergencyContact(name: '  Sara  ', phone: ' 0500-000-001 '),
      );

      final contacts = await service.getContacts();
      expect(contacts, hasLength(1));
      expect(contacts.first.name, 'Sara');
      expect(contacts.first.phone, '0500000001');
    });

    test('does not add duplicate contact by normalized phone', () async {
      await service.addContact(
        const EmergencyContact(name: 'Ali', phone: '0500000002'),
      );
      await service.addContact(
        const EmergencyContact(name: 'Ali 2', phone: '0500-000-002'),
      );

      final contacts = await service.getContacts();
      expect(contacts, hasLength(1));
      expect(contacts.first.name, 'Ali');
    });

    test('ignores blank contact fields', () async {
      await service.addContact(
        const EmergencyContact(name: '   ', phone: '0500000003'),
      );
      await service.addContact(
        const EmergencyContact(name: 'Lama', phone: '   '),
      );

      final contacts = await service.getContacts();
      expect(contacts, isEmpty);
    });

    test('enforces maxContacts limit', () async {
      await service.addContact(
        const EmergencyContact(name: 'A', phone: '0500000011'),
      );
      await service.addContact(
        const EmergencyContact(name: 'B', phone: '0500000012'),
      );
      await service.addContact(
        const EmergencyContact(name: 'C', phone: '0500000013'),
      );
      await service.addContact(
        const EmergencyContact(name: 'D', phone: '0500000014'),
      );

      final contacts = await service.getContacts();
      expect(contacts, hasLength(EmergencyContactsService.maxContacts));
      expect(contacts.map((c) => c.phone), isNot(contains('0500000014')));
    });

    test('removeContact normalizes input phone', () async {
      await service.addContact(
        const EmergencyContact(name: 'Nora', phone: '0500000099'),
      );
      await service.removeContact('0500-000-099');

      final contacts = await service.getContacts();
      expect(contacts, isEmpty);
    });
  });
}
