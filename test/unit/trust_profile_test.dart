import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/profile/domain/trust_profile.dart';

void main() {
  group('TrustProfile', () {
    const ts = '2026-02-16T12:00:00.000Z';

    test('fromJson parses all fields', () {
      final tp = TrustProfile.fromJson({
        'user_id': 'u1',
        'trust_score': 85,
        'trust_badge': 'gold',
        'junior_trusted': true,
        'computed_at': ts,
        'evidence': <String, dynamic>{
          'total_trips': 120,
          'rating_avg': 4.9,
        },
      });
      expect(tp.userId, 'u1');
      expect(tp.trustScore, 85);
      expect(tp.trustBadge, 'gold');
      expect(tp.juniorTrusted, true);
      expect(tp.computedAt, DateTime.utc(2026, 2, 16, 12));
      expect(tp.evidence['total_trips'], 120);
    });

    test('juniorTrusted defaults to false', () {
      final tp = TrustProfile.fromJson({
        'user_id': 'u2',
        'trust_score': 40,
        'trust_badge': 'bronze',
        'computed_at': ts,
      });
      expect(tp.juniorTrusted, false);
    });

    test('evidence defaults to empty map', () {
      final tp = TrustProfile.fromJson({
        'user_id': 'u3',
        'trust_score': 60,
        'trust_badge': 'silver',
        'computed_at': ts,
      });
      expect(tp.evidence, isEmpty);
    });
  });
}
