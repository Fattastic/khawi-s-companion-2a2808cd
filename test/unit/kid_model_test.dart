import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/junior/domain/kid.dart';

void main() {
  group('Kid', () {
    test('fromJson parses all fields', () {
      final k = Kid.fromJson({
        'id': 'k1',
        'parent_id': 'p1',
        'name': 'سارة',
        'avatar_url': 'https://img.co/sara.png',
        'school_name': 'مدرسة الأمل',
        'notes': 'ينتظر عند البوابة الشرقية',
      });
      expect(k.id, 'k1');
      expect(k.parentId, 'p1');
      expect(k.name, 'سارة');
      expect(k.avatarUrl, 'https://img.co/sara.png');
      expect(k.schoolName, 'مدرسة الأمل');
      expect(k.notes, 'ينتظر عند البوابة الشرقية');
    });

    test('fromJson handles nulls for optional fields', () {
      final k = Kid.fromJson({
        'id': 'k2',
        'parent_id': 'p2',
        'name': 'Omar',
      });
      expect(k.avatarUrl, isNull);
      expect(k.schoolName, isNull);
      expect(k.notes, isNull);
    });

    test('toJson round-trips', () {
      final k = Kid.fromJson({
        'id': 'k3',
        'parent_id': 'p3',
        'name': 'Fatimah',
        'school_name': 'KFUPM School',
      });
      final j = k.toJson();
      expect(j['id'], 'k3');
      expect(j['parent_id'], 'p3');
      expect(j['name'], 'Fatimah');
      expect(j['school_name'], 'KFUPM School');
      expect(j['avatar_url'], isNull);

      final k2 = Kid.fromJson(j);
      expect(k2.id, k.id);
      expect(k2.name, k.name);
    });
  });
}
