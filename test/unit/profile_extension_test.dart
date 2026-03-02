import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/profile/domain/profile_extension.dart';

void main() {
  group('ProfileExtension', () {
    final fullJson = <String, dynamic>{
      'user_id': 'u1',
      'roles': ['passenger', 'driver'],
      'city': 'Riyadh',
      'neighborhood': 'Al Olaya',
      'activity_windows': [
        {
          'window': 'morning',
          'days': [1, 2, 3, 4, 5],
        },
        {
          'window': 'evening',
          'days': [5, 6],
        },
      ],
      'purposes': ['work', 'school'],
      'vehicle_info': {
        'owns_car': true,
        'type': 'sedan',
        'has_ac': true,
        'has_child_seat': false,
        'condition': 'excellent',
      },
      'family_context': {
        'is_parent': true,
        'family_driver_willing': true,
      },
    };

    test('fromJson parses all fields', () {
      final p = ProfileExtension.fromJson(fullJson);
      expect(p.userId, 'u1');
      expect(p.roles, ['passenger', 'driver']);
      expect(p.city, 'Riyadh');
      expect(p.neighborhood, 'Al Olaya');
      expect(p.activityWindows.length, 2);
      expect(p.activityWindows.first.window, 'morning');
      expect(p.activityWindows.first.days, [1, 2, 3, 4, 5]);
      expect(p.purposes, ['work', 'school']);
      expect(p.vehicleInfo, isNotNull);
      expect(p.vehicleInfo!.ownsCar, true);
      expect(p.vehicleInfo!.hasAc, true);
      expect(p.familyContext, isNotNull);
      expect(p.familyContext!.isParent, true);
    });

    test('fromJson handles missing optional fields', () {
      final minimal = <String, dynamic>{
        'user_id': 'u2',
      };
      final p = ProfileExtension.fromJson(minimal);
      expect(p.roles, isEmpty);
      expect(p.city, isNull);
      expect(p.activityWindows, isEmpty);
      expect(p.purposes, isEmpty);
      expect(p.vehicleInfo, isNull);
      expect(p.familyContext, isNull);
    });

    test('toJson round-trips all fields', () {
      final p = ProfileExtension.fromJson(fullJson);
      final out = p.toJson();
      expect(out['user_id'], 'u1');
      expect(out['roles'], ['passenger', 'driver']);
      expect(out['city'], 'Riyadh');
      expect((out['activity_windows'] as List).length, 2);
      expect(out['vehicle_info'], isNotNull);
      expect(out['family_context'], isNotNull);
    });
  });

  group('ActivityWindow', () {
    test('fromJson parses window and days', () {
      final w = ActivityWindow.fromJson({
        'window': 'afternoon',
        'days': [3, 4],
      });
      expect(w.window, 'afternoon');
      expect(w.days, [3, 4]);
    });

    test('fromJson defaults days to empty list', () {
      final w = ActivityWindow.fromJson({'window': 'evening'});
      expect(w.days, isEmpty);
    });

    test('toJson returns correct map', () {
      const w = ActivityWindow(window: 'morning', days: [1, 2]);
      expect(w.toJson(), {
        'window': 'morning',
        'days': [1, 2],
      });
    });
  });

  group('VehicleInfo', () {
    test('fromJson parses all fields', () {
      final v = VehicleInfo.fromJson({
        'owns_car': true,
        'type': 'SUV',
        'has_ac': true,
        'has_child_seat': true,
        'condition': 'excellent',
      });
      expect(v.ownsCar, true);
      expect(v.type, 'SUV');
      expect(v.hasAc, true);
      expect(v.hasChildSeat, true);
      expect(v.condition, 'excellent');
    });

    test('fromJson uses defaults when fields missing', () {
      final v = VehicleInfo.fromJson(<String, dynamic>{});
      expect(v.ownsCar, false);
      expect(v.type, isNull);
      expect(v.hasAc, false);
      expect(v.hasChildSeat, false);
      expect(v.condition, 'good');
    });

    test('toJson round-trips', () {
      final v = VehicleInfo.fromJson({
        'owns_car': true,
        'type': 'sedan',
        'has_ac': true,
        'has_child_seat': false,
        'condition': 'acceptable',
      });
      final out = v.toJson();
      expect(out['owns_car'], true);
      expect(out['type'], 'sedan');
      expect(out['condition'], 'acceptable');
    });
  });

  group('FamilyContext', () {
    test('fromJson parses all fields', () {
      final f = FamilyContext.fromJson({
        'is_parent': true,
        'family_driver_willing': false,
      });
      expect(f.isParent, true);
      expect(f.familyDriverWilling, false);
    });

    test('fromJson defaults to false', () {
      final f = FamilyContext.fromJson(<String, dynamic>{});
      expect(f.isParent, false);
      expect(f.familyDriverWilling, false);
    });

    test('toJson round-trips', () {
      const f = FamilyContext(isParent: true, familyDriverWilling: true);
      expect(f.toJson(), {
        'is_parent': true,
        'family_driver_willing': true,
      });
    });
  });
}
