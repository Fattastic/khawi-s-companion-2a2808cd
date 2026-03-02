import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/profile/domain/user_badge.dart';

void main() {
  group('BadgeType', () {
    test('fromString parses all types', () {
      expect(BadgeTypeX.fromString('behavior'), BadgeType.behavior);
      expect(BadgeTypeX.fromString('contribution'), BadgeType.contribution);
      expect(BadgeTypeX.fromString('family'), BadgeType.family);
    });

    test('fromString defaults to behavior', () {
      expect(BadgeTypeX.fromString('unknown'), BadgeType.behavior);
      expect(BadgeTypeX.fromString(null), BadgeType.behavior);
    });

    test('displayName returns English', () {
      expect(BadgeType.behavior.displayName, 'Behavior');
      expect(BadgeType.contribution.displayName, 'Contribution');
      expect(BadgeType.family.displayName, 'Family & Trust');
    });

    test('displayNameAr returns Arabic', () {
      expect(BadgeType.behavior.displayNameAr, 'السلوك');
      expect(BadgeType.contribution.displayNameAr, 'المساهمة');
      expect(BadgeType.family.displayNameAr, 'العائلة والثقة');
    });
  });

  group('UserBadge', () {
    final json = <String, dynamic>{
      'id': 'b1',
      'key': 'safe_driver',
      'type': 'behavior',
      'name_en': 'Safe Driver',
      'name_ar': 'سائق آمن',
      'description_en': 'Awarded for safe driving record',
      'description_ar': 'تُمنح لسجل قيادة آمن',
      'is_visible': true,
      'icon_url': 'https://img.co/badge.png',
      'earned_at': '2026-02-16T10:00:00.000Z',
    };

    test('fromJson parses all fields', () {
      final b = UserBadge.fromJson(json);
      expect(b.id, 'b1');
      expect(b.key, 'safe_driver');
      expect(b.type, BadgeType.behavior);
      expect(b.nameEn, 'Safe Driver');
      expect(b.nameAr, 'سائق آمن');
      expect(b.isVisible, true);
      expect(b.iconUrl, 'https://img.co/badge.png');
      expect(b.isActive, true); // no revokedAt
    });

    test('isActive is false when revoked', () {
      final b = UserBadge.fromJson({
        ...json,
        'revoked_at': '2026-03-01T10:00:00.000Z',
      });
      expect(b.isActive, false);
    });

    test('fromJson handles joined query with badges sub-object', () {
      final b = UserBadge.fromJson({
        'id': 'ub1',
        'earned_at': '2026-02-16T10:00:00.000Z',
        'badges': {
          'id': 'b1',
          'key': 'safe_driver',
          'type': 'contribution',
          'name_en': 'Milestone',
          'name_ar': 'إنجاز',
        },
      });
      expect(b.id, 'ub1');
      expect(b.key, 'safe_driver');
      expect(b.type, BadgeType.contribution);
    });

    test('name returns localized value', () {
      final b = UserBadge.fromJson(json);
      expect(b.name(true), 'سائق آمن'); // RTL
      expect(b.name(false), 'Safe Driver');
    });

    test('description returns localized value', () {
      final b = UserBadge.fromJson(json);
      expect(b.description(true), contains('آمن'));
      expect(b.description(false), contains('safe driving'));
    });

    test('defaults isVisible to true when missing', () {
      final b = UserBadge.fromJson({
        ...json,
        'is_visible': null,
      });
      expect(b.isVisible, true);
    });
  });
}
