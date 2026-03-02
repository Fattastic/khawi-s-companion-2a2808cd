import 'package:khawi_flutter/services/xp_policy.dart';

/// TS counterpart: `utils/xpCalculator.ts`.
///
/// The actual calculation rules live in [XPPolicy]. This file exists as a
/// friendly, discoverable facade in a `utils/` location.
int calculateTripXp({
  required double distanceKm,
  required bool isCarpooling,
}) {
  return XPPolicy.calculateTripXP(
    distKm: distanceKm,
    isCarpooling: isCarpooling,
  );
}

int xpLevelForTotal(int totalXp) => XPPolicy.getLevel(totalXp);

int xpNeededForNextLevel(int currentLevel) =>
    XPPolicy.xpForNextLevel(currentLevel);
