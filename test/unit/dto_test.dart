import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/data/dto/edge/xp_calculate_dto.dart';
import 'package:khawi_flutter/data/dto/edge/verify_identity_dto.dart';

void main() {
  group('DTO Serialization Tests', () {
    test('XpCalculateRequest serializes correctly', () {
      final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
      final req = XpCalculateRequest(
        userId: 'user_123',
        baseXp: 100,
        occurredAt: now,
        context: {'source': 'manual_test'},
      );

      final json = req.toJson();

      expect(json['user_id'], 'user_123');
      expect(json['base_xp'], 100);
      expect(json['occurred_at'], now.toIso8601String());
      expect(json['context']['source'], 'manual_test');
    });

    test('XpCalculateResponse deserializes correctly', () {
      final json = {
        'awarded_xp': 150,
        'multiplier': 1.5,
        'breakdown': {'base': 100, 'bonus': 50},
      };

      final res = XpCalculateResponse.fromJson(json);

      expect(res.awardedXp, 150);
      expect(res.multiplier, 1.5);
      expect(res.breakdown['base'], 100);
    });

    test('VerifyIdentityRequest serializes correctly', () {
      const req = VerifyIdentityRequest(
        userId: 'user_456',
        dryRun: true,
      );

      final json = req.toJson();

      expect(json['user_id'], 'user_456');
      expect(json['dry_run'], true);
    });

    test('VerifyIdentityResponse deserializes correctly', () {
      final json = {
        'verified': true,
        'status': 'verified',
        'message': 'User is verified',
      };

      final res = VerifyIdentityResponse.fromJson(json);

      expect(res.verified, true);
      expect(res.status, 'verified');
      expect(res.message, 'User is verified');
    });
  });
}
