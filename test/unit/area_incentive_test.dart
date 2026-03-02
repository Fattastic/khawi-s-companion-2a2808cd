import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/domain/area_incentive.dart';

void main() {
  group('AreaIncentive', () {
    const ts = '2026-04-10T06:00:00.000Z';

    test('fromJson parses all fields (note: dynamic_xp_multiplier key)', () {
      final ai = AreaIncentive.fromJson({
        'area_key': 'riyadh-north',
        'time_bucket': '06:00-09:00',
        'dynamic_xp_multiplier': 2.5,
        'reason_tag': 'morning_rush',
        'computed_at': ts,
        'meta': <String, dynamic>{'surge': true},
      });
      expect(ai.areaKey, 'riyadh-north');
      expect(ai.timeBucket, '06:00-09:00');
      expect(ai.multiplier, 2.5);
      expect(ai.reasonTag, 'morning_rush');
      expect(ai.computedAt, DateTime.utc(2026, 4, 10, 6));
      expect(ai.meta['surge'], true);
    });

    test('meta defaults to empty map', () {
      final ai = AreaIncentive.fromJson({
        'area_key': 'jeddah-south',
        'time_bucket': '12:00-15:00',
        'dynamic_xp_multiplier': 1.0,
        'reason_tag': 'baseline',
        'computed_at': ts,
      });
      expect(ai.meta, isEmpty);
    });
  });
}
