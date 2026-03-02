import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/smart_commute/domain/smart_commute_prefs.dart';

void main() {
  group('SmartCommutePrefs', () {
    test('maps womenOnly true into request flag', () {
      const prefs = SmartCommutePrefs(
        originLat: 24.7,
        originLng: 46.6,
        destLat: 24.8,
        destLng: 46.7,
        maxResults: 12,
        womenOnly: true,
      );

      final req = prefs.toMatchRequest();
      expect(req.womenOnly, true);
      expect(req.maxResults, 12);
    });

    test('maps womenOnly false to nullable field', () {
      const prefs = SmartCommutePrefs(
        originLat: 24.7,
        originLng: 46.6,
        destLat: 24.8,
        destLng: 46.7,
        maxResults: 8,
        womenOnly: false,
      );

      final req = prefs.toMatchRequest();
      expect(req.womenOnly, isNull);
      expect(req.maxResults, 8);
    });

    test('default prefs are valid', () {
      final defaults = defaultSmartCommutePrefs();

      expect(defaults.maxResults, 10);
      expect(defaults.originLat, greaterThan(0));
      expect(defaults.originLng, greaterThan(0));
      expect(defaults.departureTime, isNotNull);
    });
  });
}
