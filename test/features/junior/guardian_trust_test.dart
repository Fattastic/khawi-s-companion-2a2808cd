import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';

void main() {
  group('Guardian Safety Logic', () {
    test('JuniorRun should only be authorized by its parentId', () {
      final run = JuniorRun(
        id: 'r1',
        kidId: 'k1',
        parentId: 'guardian_a',
        status: 'planned',
        pickupLat: 0,
        pickupLng: 0,
        dropoffLat: 0,
        dropoffLng: 0,
        pickupTime: DateTime.now(),
      );

      expect(run.isAuthorizedBy('guardian_a'), isTrue);
      expect(run.isAuthorizedBy('stranger_x'), isFalse);
    });
  });
}
