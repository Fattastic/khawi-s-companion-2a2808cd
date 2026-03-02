// XP Policy Tests
// Validates XP calculation logic for various scenarios.

import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/services/xp_policy.dart';

void main() {
  group('XPPolicy', () {
    group('calculateTripXP', () {
      test('returns base + distance XP for standard trip', () {
        // 10 km trip
        final xp = XPPolicy.calculateTripXP(distKm: 10.0, isCarpooling: false);
        // base 50 + 10*5 = 100
        expect(xp, 100);
      });

      test('adds carpooling bonus when carpooling', () {
        final xp = XPPolicy.calculateTripXP(distKm: 10.0, isCarpooling: true);
        // base 50 + 10*5 + 20 = 120
        expect(xp, 120);
      });

      test('minimum XP is base for very short trips', () {
        final xp = XPPolicy.calculateTripXP(distKm: 0.5, isCarpooling: false);
        // base 50 + round(0.5*5) = 50 + 3 = 53
        expect(xp, 53);
      });

      test('longer trips get proportionally more XP', () {
        final shortTrip =
            XPPolicy.calculateTripXP(distKm: 5.0, isCarpooling: false);
        final longTrip =
            XPPolicy.calculateTripXP(distKm: 20.0, isCarpooling: false);

        expect(longTrip, greaterThan(shortTrip));
        // 50 + 5*5 = 75 vs 50 + 20*5 = 150
        expect(shortTrip, 75);
        expect(longTrip, 150);
      });
    });

    group('getLevel', () {
      test('returns level 1 for 0 XP', () {
        expect(XPPolicy.getLevel(0), 1);
      });

      test('returns level 1 for XP below first threshold', () {
        expect(XPPolicy.getLevel(50), 1);
        expect(XPPolicy.getLevel(99), 1);
      });

      test('returns level 2 at 100 XP', () {
        expect(XPPolicy.getLevel(100), 2);
      });

      test('returns level 3 at 300 XP', () {
        expect(XPPolicy.getLevel(300), 3);
        expect(XPPolicy.getLevel(599), 3);
      });

      test('returns level 4 at 600 XP', () {
        expect(XPPolicy.getLevel(600), 4);
      });

      test('returns level 5 at 1000+ XP', () {
        expect(XPPolicy.getLevel(1000), 5);
        expect(XPPolicy.getLevel(5000), 5);
      });
    });

    group('xpForNextLevel', () {
      test('returns correct XP threshold for next level', () {
        // At level 1, threshold for level 2 is 100
        expect(XPPolicy.xpForNextLevel(1), 100);

        // At level 2, threshold for level 3 is 300
        expect(XPPolicy.xpForNextLevel(2), 300);

        // At level 4, threshold for level 5 is 1000
        expect(XPPolicy.xpForNextLevel(4), 1000);
      });

      test('returns -1 for max level', () {
        final needed = XPPolicy.xpForNextLevel(5);
        expect(needed, -1);
      });
    });
  });
}
