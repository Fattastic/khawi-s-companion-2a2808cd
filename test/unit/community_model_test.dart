import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/community/domain/community.dart';

void main() {
  group('CommunityType', () {
    test('fromString returns matching enum', () {
      expect(
        CommunityType.fromString('neighborhood'),
        CommunityType.neighborhood,
      );
      expect(CommunityType.fromString('workplace'), CommunityType.workplace);
      expect(CommunityType.fromString('school'), CommunityType.school);
      expect(CommunityType.fromString('custom'), CommunityType.custom);
    });

    test('fromString defaults to custom for unknown value', () {
      expect(CommunityType.fromString('alien'), CommunityType.custom);
      expect(CommunityType.fromString(null), CommunityType.custom);
    });

    test('label returns Arabic for ar locale', () {
      expect(CommunityType.neighborhood.label('ar'), 'حارة');
      expect(CommunityType.workplace.label('ar'), 'مقر عمل');
    });

    test('label returns English for en locale', () {
      expect(CommunityType.neighborhood.label('en'), 'Neighborhood');
      expect(CommunityType.school.label('en'), 'School / University');
    });
  });

  group('Community', () {
    final now = DateTime(2026, 2, 16);
    final json = <String, dynamic>{
      'id': 'c1',
      'name': 'KFUPM Carpool',
      'name_ar': 'نادي مشاركة جامعة البترول',
      'description': 'University carpooling',
      'type': 'school',
      'icon_url': 'https://img.co/icon.png',
      'cover_url': 'https://img.co/cover.png',
      'lat': 26.307,
      'lng': 50.144,
      'radius_km': 10,
      'creator_id': 'u1',
      'member_count': 42,
      'is_verified': true,
      'is_active': true,
      'metadata': <String, dynamic>{'campus': 'main'},
      'created_at': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final c = Community.fromJson(json);
      expect(c.id, 'c1');
      expect(c.name, 'KFUPM Carpool');
      expect(c.nameAr, 'نادي مشاركة جامعة البترول');
      expect(c.type, CommunityType.school);
      expect(c.lat, 26.307);
      expect(c.lng, 50.144);
      expect(c.radiusKm, 10);
      expect(c.memberCount, 42);
      expect(c.isVerified, true);
      expect(c.isActive, true);
      expect(c.metadata['campus'], 'main');
    });

    test('fromJson uses defaults for optional fields', () {
      final minimal = <String, dynamic>{
        'id': 'c2',
        'name': 'Minimal',
        'created_at': now.toIso8601String(),
      };
      final c = Community.fromJson(minimal);
      expect(c.type, CommunityType.custom);
      expect(c.radiusKm, 5);
      expect(c.memberCount, 0);
      expect(c.isVerified, false);
      expect(c.isActive, true);
      expect(c.metadata, isEmpty);
    });

    test('toJson round-trips through fromJson', () {
      final c = Community.fromJson(json);
      final out = c.toJson();
      expect(out['id'], 'c1');
      expect(out['name'], 'KFUPM Carpool');
      expect(out['type'], 'school');
      expect(out['radius_km'], 10);
      expect(out['is_verified'], true);
    });

    test('toInsertJson excludes id and created_at', () {
      final c = Community.fromJson(json);
      final insert = c.toInsertJson();
      expect(insert.containsKey('id'), false);
      expect(insert.containsKey('created_at'), false);
      expect(insert['name'], 'KFUPM Carpool');
    });

    test('displayName returns Arabic when locale is ar and nameAr set', () {
      final c = Community.fromJson(json);
      expect(c.displayName('ar'), 'نادي مشاركة جامعة البترول');
    });

    test('displayName returns name when locale is en', () {
      final c = Community.fromJson(json);
      expect(c.displayName('en'), 'KFUPM Carpool');
    });

    test('displayName falls back to name when nameAr is null', () {
      final c = Community.fromJson({...json, 'name_ar': null});
      expect(c.displayName('ar'), 'KFUPM Carpool');
    });

    test('typeEmoji returns correct emoji for each type', () {
      expect(
        Community.fromJson({...json, 'type': 'neighborhood'}).typeEmoji,
        '🏘️',
      );
      expect(
        Community.fromJson({...json, 'type': 'workplace'}).typeEmoji,
        '🏢',
      );
      expect(
        Community.fromJson({...json, 'type': 'school'}).typeEmoji,
        '🎓',
      );
      expect(
        Community.fromJson({...json, 'type': 'custom'}).typeEmoji,
        '👥',
      );
    });
  });

  group('CommunityRole', () {
    test('fromString parses known roles', () {
      expect(CommunityRole.fromString('admin'), CommunityRole.admin);
      expect(CommunityRole.fromString('moderator'), CommunityRole.moderator);
      expect(CommunityRole.fromString('member'), CommunityRole.member);
    });

    test('fromString defaults to member for unknown', () {
      expect(CommunityRole.fromString('king'), CommunityRole.member);
      expect(CommunityRole.fromString(null), CommunityRole.member);
    });
  });

  group('CommunityMembership', () {
    test('fromJson parses without joined community', () {
      final m = CommunityMembership.fromJson({
        'community_id': 'c1',
        'user_id': 'u1',
        'role': 'admin',
        'joined_at': '2026-01-01T00:00:00.000Z',
      });
      expect(m.communityId, 'c1');
      expect(m.role, CommunityRole.admin);
      expect(m.community, isNull);
    });

    test('fromJson parses with joined community data', () {
      final m = CommunityMembership.fromJson({
        'community_id': 'c1',
        'user_id': 'u1',
        'role': 'member',
        'joined_at': '2026-01-01T00:00:00.000Z',
        'communities': {
          'id': 'c1',
          'name': 'Test',
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      });
      expect(m.community, isNotNull);
      expect(m.community!.name, 'Test');
    });
  });

  group('CommunityRide', () {
    test('fromJson parses all fields', () {
      final r = CommunityRide.fromJson({
        'id': 'cr1',
        'community_id': 'c1',
        'trip_id': 't1',
        'posted_by': 'u1',
        'message': 'Heading out at 7am',
        'created_at': '2026-02-16T07:00:00.000Z',
      });
      expect(r.id, 'cr1');
      expect(r.message, 'Heading out at 7am');
      expect(r.tripData, isNull);
    });
  });
}
