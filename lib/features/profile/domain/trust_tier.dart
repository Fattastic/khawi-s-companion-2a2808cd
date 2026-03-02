/// Trust tier levels for safety-based access control.
enum TrustTier {
  /// New or limited data
  bronze,

  /// Reliable participation
  silver,

  /// Proven safe & consistent
  gold,

  /// Elite community trust
  platinum,
}

/// Extension for parsing and comparison
extension TrustTierX on TrustTier {
  static TrustTier fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'platinum':
        return TrustTier.platinum;
      case 'gold':
        return TrustTier.gold;
      case 'silver':
        return TrustTier.silver;
      default:
        return TrustTier.bronze;
    }
  }

  static TrustTier fromProfile({
    required bool isIdentityVerified,
    String? trustBadge,
  }) {
    if (trustBadge != null) {
      return fromString(trustBadge);
    }
    return isIdentityVerified ? TrustTier.silver : TrustTier.bronze;
  }

  String get displayName {
    switch (this) {
      case TrustTier.bronze:
        return 'Bronze';
      case TrustTier.silver:
        return 'Silver';
      case TrustTier.gold:
        return 'Gold';
      case TrustTier.platinum:
        return 'Platinum';
    }
  }

  String get displayNameAr {
    switch (this) {
      case TrustTier.bronze:
        return 'برونزي';
      case TrustTier.silver:
        return 'فضي';
      case TrustTier.gold:
        return 'ذهبي';
      case TrustTier.platinum:
        return 'بلاتيني';
    }
  }

  /// Returns true if this tier is at least the required tier
  bool isAtLeast(TrustTier required) {
    return index >= required.index;
  }
}
