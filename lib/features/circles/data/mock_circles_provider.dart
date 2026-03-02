import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/commute_circle.dart';

final mockCirclesProvider = Provider<List<CommuteCircle>>((ref) {
  return [
    const CommuteCircle(
      id: 'c1',
      neighborhoodId: 'Al Malqa',
      destinationId: 'Digital City',
      routeId: 'r1',
      title: 'Morning Work Hub',
      memberIds: ['u1', 'u2', 'u3'],
      commitments: [],
      schedule: {
        1: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)],
        2: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)],
        3: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)],
        4: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)],
        5: [TimeOfDayRange(startMinutes: 450, endMinutes: 480)],
      },
      reliabilityScore: 0.98,
    ),
    const CommuteCircle(
      id: 'c2',
      neighborhoodId: 'Al Sahafa',
      destinationId: 'KSU Female Campus',
      routeId: 'r2',
      title: 'Uni Route - Women Only',
      memberIds: ['u4', 'u5'],
      commitments: [],
      schedule: {
        1: [TimeOfDayRange(startMinutes: 480, endMinutes: 510)],
        3: [TimeOfDayRange(startMinutes: 480, endMinutes: 510)],
      },
      womenOnly: true,
      reliabilityScore: 0.85,
    ),
  ];
});
