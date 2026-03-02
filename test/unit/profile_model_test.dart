import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/profile/domain/base_profile_completeness.dart';

void main() {
  group('roleFromString / roleToString', () {
    test('round-trips all roles', () {
      for (final r in UserRole.values) {
        expect(roleFromString(roleToString(r)), r);
      }
    });

    test('unknown string defaults to passenger', () {
      expect(roleFromString('admin'), UserRole.passenger);
      expect(roleFromString(''), UserRole.passenger);
    });
  });

  group('Profile', () {
    const ts = '2026-02-16T08:00:00.000Z';
    final fullJson = <String, dynamic>{
      'id': 'u1',
      'full_name': 'Ahmed Al-Qahtani',
      'avatar_url': 'https://img.co/avatar.png',
      'role': 'driver',
      'is_premium': true,
      'is_verified': true,
      'total_xp': 1200,
      'redeemable_xp': 300,
      'gender': 'male',
      'neighborhood_id': 'n1',
      'trust_score': 92.5,
      'trust_badge': 'gold',
      'xp_throttle': false,
      'xp_throttle_until': null,
      'is_identity_verified': true,
      'identity_verified_at': ts,
      'identity_provider': 'nafath',
      'vehicle_verification_status': 'approved',
      'vehicle_verified_at': ts,
      'vehicle_plate_number': 'ABC 1234',
      'vehicle_model': 'Toyota Camry 2023',
      'average_rating': 4.8,
      'total_ratings': 55,
    };

    test('fromJson parses all fields', () {
      final p = Profile.fromJson(fullJson);
      expect(p.id, 'u1');
      expect(p.fullName, 'Ahmed Al-Qahtani');
      expect(p.avatarUrl, 'https://img.co/avatar.png');
      expect(p.role, UserRole.driver);
      expect(p.isPremium, true);
      expect(p.isVerified, true);
      expect(p.totalXp, 1200);
      expect(p.redeemableXp, 300);
      expect(p.gender, 'male');
      expect(p.trustScore, 92.5);
      expect(p.trustBadge, 'gold');
      expect(p.isIdentityVerified, true);
      expect(p.identityProvider, 'nafath');
      expect(p.vehicleVerificationStatus, 'approved');
      expect(p.vehiclePlateNumber, 'ABC 1234');
      expect(p.vehicleModel, 'Toyota Camry 2023');
      expect(p.averageRating, 4.8);
      expect(p.totalRatings, 55);
    });

    test('fromJson uses defaults for missing fields', () {
      final p = Profile.fromJson({'id': 'u2'});
      expect(p.fullName, '');
      expect(p.role, isNull);
      expect(p.isPremium, false);
      expect(p.isVerified, false);
      expect(p.totalXp, 0);
      expect(p.redeemableXp, 0);
      expect(p.xpThrottle, false);
      expect(p.isIdentityVerified, false);
      expect(p.vehicleVerificationStatus, 'none');
      expect(p.totalRatings, 0);
    });

    test('toJson round-trips', () {
      final p = Profile.fromJson(fullJson);
      final j = p.toJson();
      expect(j['id'], 'u1');
      expect(j['full_name'], 'Ahmed Al-Qahtani');
      expect(j['role'], 'driver');
      expect(j['is_premium'], true);
      expect(j['total_xp'], 1200);
      expect(j['vehicle_plate_number'], 'ABC 1234');

      final p2 = Profile.fromJson(j);
      expect(p2.id, p.id);
      expect(p2.fullName, p.fullName);
      expect(p2.role, p.role);
      expect(p2.totalXp, p.totalXp);
    });

    test('isComplete requires fullName + role', () {
      expect(
        Profile.fromJson({...fullJson, 'full_name': '', 'role': 'driver'})
            .isComplete,
        false,
      );
      expect(
        Profile.fromJson({...fullJson, 'full_name': 'X', 'role': null})
            .isComplete,
        false,
      );
      expect(
        Profile.fromJson({...fullJson, 'full_name': 'X', 'role': 'driver'})
            .isComplete,
        true,
      );
    });

    test('isMinimalProfileComplete only needs non-empty fullName', () {
      expect(Profile.fromJson({'id': 'u3'}).isMinimalProfileComplete, false);
      expect(
        Profile.fromJson({'id': 'u3', 'full_name': 'A'})
            .isMinimalProfileComplete,
        true,
      );
    });

    test('isDriverTrustComplete requires identity + vehicle approved', () {
      final p = Profile.fromJson(fullJson);
      expect(p.isDriverTrustComplete, true);

      final p2 = Profile.fromJson({
        ...fullJson,
        'is_identity_verified': false,
      });
      expect(p2.isDriverTrustComplete, false);

      final p3 = Profile.fromJson({
        ...fullJson,
        'vehicle_verification_status': 'pending',
      });
      expect(p3.isDriverTrustComplete, false);
    });
  });

  group('isBaseProfileComplete', () {
    test('returns false for null', () {
      expect(isBaseProfileComplete(null), false);
    });

    test('returns false for empty fullName', () {
      final p = Profile.fromJson({'id': 'u1', 'full_name': ''});
      expect(isBaseProfileComplete(p), false);
    });

    test('returns false for whitespace-only fullName', () {
      final p = Profile.fromJson({'id': 'u1', 'full_name': '   '});
      expect(isBaseProfileComplete(p), false);
    });

    test('returns true for non-empty fullName', () {
      final p = Profile.fromJson({'id': 'u1', 'full_name': 'Ahmed'});
      expect(isBaseProfileComplete(p), true);
    });
  });
}
