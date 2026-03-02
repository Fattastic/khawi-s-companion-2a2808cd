class XPPolicy {
  // Constants for XP calculation
  static const int baseTripXP = 50;
  static const int perKmXP = 5;
  static const int carpoolingBonus = 20;

  // Level thresholds
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
  };

  /// Calculates XP for a completed trip
  static int calculateTripXP({
    required double distKm,
    required bool isCarpooling,
  }) {
    int xp = baseTripXP;
    xp += (distKm * perKmXP).round();
    if (isCarpooling) {
      xp += carpoolingBonus;
    }
    return xp;
  }

  /// Returns current level based on total XP
  static int getLevel(int totalXP) {
    int level = 1;
    for (var entry in levelThresholds.entries) {
      if (totalXP >= entry.value) {
        level = entry.key;
      } else {
        break;
      }
    }
    return level;
  }

  /// Returns XP needed for next level
  static int xpForNextLevel(int currentLevel) {
    if (levelThresholds.containsKey(currentLevel + 1)) {
      return levelThresholds[currentLevel + 1]!;
    }
    return -1; // Max level
  }
}
