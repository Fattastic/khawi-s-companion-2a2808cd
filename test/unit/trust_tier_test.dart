import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';

void main() {
  group('TrustTier', () {
    test('fromString parses all tiers', () {
      expect(TrustTierX.fromString('bronze'), TrustTier.bronze);
      expect(TrustTierX.fromString('silver'), TrustTier.silver);
      expect(TrustTierX.fromString('gold'), TrustTier.gold);
      expect(TrustTierX.fromString('platinum'), TrustTier.platinum);
    });

    test('fromString is case-insensitive', () {
      expect(TrustTierX.fromString('GOLD'), TrustTier.gold);
      expect(TrustTierX.fromString('Silver'), TrustTier.silver);
    });

    test('fromString defaults to bronze for unknown', () {
      expect(TrustTierX.fromString('diamond'), TrustTier.bronze);
      expect(TrustTierX.fromString(null), TrustTier.bronze);
    });

    test('displayName returns English names', () {
      expect(TrustTier.bronze.displayName, 'Bronze');
      expect(TrustTier.silver.displayName, 'Silver');
      expect(TrustTier.gold.displayName, 'Gold');
      expect(TrustTier.platinum.displayName, 'Platinum');
    });

    test('displayNameAr returns Arabic names', () {
      expect(TrustTier.bronze.displayNameAr, 'برونزي');
      expect(TrustTier.platinum.displayNameAr, 'بلاتيني');
    });

    test('isAtLeast compares tier order', () {
      expect(TrustTier.gold.isAtLeast(TrustTier.bronze), true);
      expect(TrustTier.gold.isAtLeast(TrustTier.silver), true);
      expect(TrustTier.gold.isAtLeast(TrustTier.gold), true);
      expect(TrustTier.gold.isAtLeast(TrustTier.platinum), false);
      expect(TrustTier.bronze.isAtLeast(TrustTier.silver), false);
    });
  });
}
