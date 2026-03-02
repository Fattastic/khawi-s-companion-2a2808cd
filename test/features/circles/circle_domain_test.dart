import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/circles/domain/entities/commute_circle.dart';

void main() {
  group('CommuteCircle', () {
    test('should detect overlapping schedules accurately', () {
      const circle1 = CommuteCircle(
        id: 'c1',
        neighborhoodId: 'n1',
        destinationId: 'd1',
        routeId: 'r1',
        title: 'Morning Work',
        memberIds: [],
        commitments: [],
        schedule: {
          1: [
            TimeOfDayRange(startMinutes: 450, endMinutes: 480),
          ], // Mon 7:30
        },
      );

      const circle2 = CommuteCircle(
        id: 'c2',
        neighborhoodId: 'n1',
        destinationId: 'd1',
        routeId: 'r2',
        title: 'Work Commute',
        memberIds: [],
        commitments: [],
        schedule: {
          1: [
            TimeOfDayRange(startMinutes: 460, endMinutes: 490),
          ], // Mon 7:40
        },
      );

      expect(circle1.hasOverlap(circle2), isTrue);
    });

    test('should not detect overlap on different days', () {
      const circle1 = CommuteCircle(
        id: 'c1',
        neighborhoodId: 'n1',
        destinationId: 'd1',
        routeId: 'r1',
        title: 'Morning Work',
        memberIds: [],
        commitments: [],
        schedule: {
          1: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)], // Mon
        },
      );

      const circle2 = CommuteCircle(
        id: 'c2',
        neighborhoodId: 'n1',
        destinationId: 'd1',
        routeId: 'r2',
        title: 'Tue Commute',
        memberIds: [],
        commitments: [],
        schedule: {
          2: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)], // Tue
        },
      );

      expect(circle1.hasOverlap(circle2), isFalse);
    });
  });
}
