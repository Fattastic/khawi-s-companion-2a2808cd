import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/subscription/domain/subscription_tier.dart';

void main() {
  group('XP habit Engine', () {
    test('Free tier should have 1.0x multiplier', () {
      expect(SubscriptionTier.free.xpMultiplier, 1.0);
    });

    test('KhawiPlus tier should have 2.0x multiplier', () {
      expect(SubscriptionTier.khawiPlus.xpMultiplier, 2.0);
    });
  });
}
