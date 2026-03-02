// DTO Serialization Tests
// Validates round-trip JSON serialization for all DTOs.

import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/data/dto/rewards/reward_dtos.dart';
import 'package:khawi_flutter/data/dto/rewards/redemption_dtos.dart';
import 'package:khawi_flutter/data/dto/badges/badge_dtos.dart';
import 'package:khawi_flutter/data/dto/trust/trust_dtos.dart';

void main() {
  group('RewardDto', () {
    test('serializes and deserializes correctly', () {
      const dto = RewardDto(
        id: 'reward-1',
        code: 'COFFEE_VOUCHER',
        titleKey: 'rewards.coffee.title',
        descriptionKey: 'rewards.coffee.desc',
        category: 'partner',
        deliveryType: 'coupon_code',
        xpCost: 500,
        isActive: true,
        requiresKhawiPlus: false,
        minTrustTier: 'silver',
        maxRedemptionsPerUser: 3,
      );

      final json = dto.toJson();
      final restored = RewardDto.fromJson(json);

      expect(restored.id, dto.id);
      expect(restored.code, dto.code);
      expect(restored.xpCost, dto.xpCost);
      expect(restored.minTrustTier, dto.minTrustTier);
      expect(restored.maxRedemptionsPerUser, dto.maxRedemptionsPerUser);
    });

    test('handles null optional fields', () {
      const dto = RewardDto(
        id: 'reward-2',
        code: 'FREE_RIDE',
        titleKey: 'rewards.ride.title',
        descriptionKey: 'rewards.ride.desc',
        category: 'functional',
        deliveryType: 'in_app',
        xpCost: 1000,
        isActive: true,
        requiresKhawiPlus: true,
        minTrustTier: 'bronze',
      );

      final json = dto.toJson();
      final restored = RewardDto.fromJson(json);

      expect(restored.maxRedemptionsPerUser, isNull);
      expect(restored.maxRedemptionsTotal, isNull);
      expect(restored.redemptionWindowStart, isNull);
    });
  });

  group('RedemptionDto', () {
    test('serializes and deserializes correctly', () {
      final dto = RedemptionDto(
        id: 'redemption-1',
        userId: 'user-123',
        rewardId: 'reward-1',
        xpCostSnapshot: 500,
        status: 'requested',
        createdAt: DateTime(2026, 2, 6, 10, 0),
        updatedAt: DateTime(2026, 2, 6, 10, 0),
      );

      final json = dto.toJson();
      final restored = RedemptionDto.fromJson(json);

      expect(restored.id, dto.id);
      expect(restored.userId, dto.userId);
      expect(restored.status, dto.status);
      expect(restored.xpCostSnapshot, dto.xpCostSnapshot);
    });
  });

  group('BadgeDto', () {
    test('serializes and deserializes correctly', () {
      const dto = BadgeDto(
        id: 'badge-1',
        code: 'EARLY_ADOPTER',
        titleKey: 'badges.early.title',
        descriptionKey: 'badges.early.desc',
        visibility: 'public',
        isActive: true,
        criteria: {'min_trips': 10},
      );

      final json = dto.toJson();
      final restored = BadgeDto.fromJson(json);

      expect(restored.code, dto.code);
      expect(restored.visibility, dto.visibility);
      expect(restored.criteria['min_trips'], 10);
    });
  });

  group('TrustStateDto', () {
    test('serializes and deserializes correctly', () {
      final dto = TrustStateDto(
        userId: 'user-123',
        tier: 'gold',
        score: 85.5,
        confidence: 0.92,
        explain: {'rating_avg': 4.8},
        updatedAt: DateTime(2026, 2, 6, 12, 0),
      );

      final json = dto.toJson();
      final restored = TrustStateDto.fromJson(json);

      expect(restored.tier, dto.tier);
      expect(restored.score, dto.score);
      expect(restored.confidence, dto.confidence);
      expect(restored.explain['rating_avg'], 4.8);
    });
  });

  group('TrustEventDto', () {
    test('serializes and deserializes correctly', () {
      final dto = TrustEventDto(
        id: 'event-1',
        userId: 'user-123',
        actor: 'system',
        eventType: 'tier_upgrade',
        fromTier: 'silver',
        toTier: 'gold',
        payload: {'reason': 'high_rating'},
        createdAt: DateTime(2026, 2, 6, 12, 0),
      );

      final json = dto.toJson();
      final restored = TrustEventDto.fromJson(json);

      expect(restored.eventType, dto.eventType);
      expect(restored.fromTier, dto.fromTier);
      expect(restored.toTier, dto.toTier);
    });
  });
}
