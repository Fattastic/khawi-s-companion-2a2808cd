import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/features/leaderboard/domain/leaderboard_entry.dart';

class LeaderboardRepo {
  LeaderboardRepo(this._client);

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> fetchTop({int limit = 20}) async {
    try {
      final List<dynamic> raw = await _client.rpc<List<dynamic>>(
        'get_global_xp_leaderboard',
        params: {'p_limit': limit},
      );

      final rows =
          raw.whereType<Map<String, dynamic>>().toList(growable: false);

      final items = rows.map(LeaderboardEntry.fromJson).toList(growable: false);
      return assignLeaderboardRanks(items);
    } catch (_) {
      return const <LeaderboardEntry>[];
    }
  }
}
