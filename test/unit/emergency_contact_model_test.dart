import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/services/emergency_contacts_service.dart';

void main() {
  group('EmergencyContact', () {
    test('toJson and fromJson round-trip preserves values', () {
      const contact = EmergencyContact(name: 'Ahmad', phone: '0500000000');

      final json = contact.toJson();
      final decoded = EmergencyContact.fromJson(json);

      expect(decoded.name, equals('Ahmad'));
      expect(decoded.phone, equals('0500000000'));
    });

    test('fromJson falls back to empty strings for missing fields', () {
      final decoded = EmergencyContact.fromJson({});

      expect(decoded.name, isEmpty);
      expect(decoded.phone, isEmpty);
    });
  });
}
