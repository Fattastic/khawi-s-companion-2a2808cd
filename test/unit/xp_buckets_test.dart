import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/xp_ledger/domain/xp_buckets.dart';

void main() {
  group('XpBuckets', () {
    test('fromJson parses all fields', () {
      final b = XpBuckets.fromJson({
        'contribution_xp': 100,
        'safety_xp': 50,
        'community_xp': 30,
        'learning_xp': 20,
        'updated_at': '2026-02-16T10:00:00.000Z',
      });
      expect(b.contributionXp, 100);
      expect(b.safetyXp, 50);
      expect(b.communityXp, 30);
      expect(b.learningXp, 20);
    });

    test('totalXp sums all buckets', () {
      final b = XpBuckets.fromJson({
        'contribution_xp': 100,
        'safety_xp': 50,
        'community_xp': 30,
        'learning_xp': 20,
        'updated_at': '2026-02-16T10:00:00.000Z',
      });
      expect(b.totalXp, 200);
    });

    test('fromJson defaults to 0 for missing fields', () {
      final b = XpBuckets.fromJson({});
      expect(b.contributionXp, 0);
      expect(b.safetyXp, 0);
      expect(b.communityXp, 0);
      expect(b.learningXp, 0);
      expect(b.totalXp, 0);
    });

    test('empty factory creates zero buckets', () {
      final b = XpBuckets.empty();
      expect(b.totalXp, 0);
      expect(b.contributionXp, 0);
    });
  });
}
