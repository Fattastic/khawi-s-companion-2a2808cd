enum SubscriptionTier {
  free,
  khawiPlus,
}

extension SubscriptionTierX on SubscriptionTier {
  double get xpMultiplier {
    switch (this) {
      case SubscriptionTier.free:
        return 1.0;
      case SubscriptionTier.khawiPlus:
        return 2.0;
    }
  }
}
