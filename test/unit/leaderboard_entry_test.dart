import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/leaderboard/domain/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry', () {
    test('fromJson maps defaults safely', () {
      final entry = LeaderboardEntry.fromJson(const <String, dynamic>{});

      expect(entry.rank, 0);
      expect(entry.userId, '');
      expect(entry.displayName, 'Khawi User');
      expect(entry.totalXp, 0);
      expect(entry.trustBadge, isNull);
    });

    test('assignLeaderboardRanks sorts by XP desc then name', () {
      final ranked = assignLeaderboardRanks([
        const LeaderboardEntry(
          rank: 0,
          userId: 'u2',
          displayName: 'Ziad',
          totalXp: 200,
        ),
        const LeaderboardEntry(
          rank: 0,
          userId: 'u1',
          displayName: 'Ahmad',
          totalXp: 300,
        ),
        const LeaderboardEntry(
          rank: 0,
          userId: 'u3',
          displayName: 'Bader',
          totalXp: 200,
        ),
      ]);

      expect(ranked[0].userId, 'u1');
      expect(ranked[0].rank, 1);
      expect(ranked[1].userId, 'u3');
      expect(ranked[1].rank, 2);
      expect(ranked[2].userId, 'u2');
      expect(ranked[2].rank, 3);
    });
  });
}
