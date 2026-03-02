import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/trusted_driver.dart';

void main() {
  group('TrustedDriver', () {
    test('fromJson parses all fields', () {
      final td = TrustedDriver.fromJson({
        'id': 'td1',
        'parent_id': 'p1',
        'driver_id': 'd1',
        'label': 'Uncle Khalid',
        'is_active': true,
      });
      expect(td.id, 'td1');
      expect(td.parentId, 'p1');
      expect(td.driverId, 'd1');
      expect(td.label, 'Uncle Khalid');
      expect(td.isActive, true);
    });

    test('fromJson handles null label', () {
      final td = TrustedDriver.fromJson({
        'id': 'td2',
        'parent_id': 'p2',
        'driver_id': 'd2',
        'is_active': false,
      });
      expect(td.label, isNull);
      expect(td.isActive, false);
    });
  });
}
