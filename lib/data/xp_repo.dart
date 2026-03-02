import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;

class XpRepo {
  XpRepo(this.sb);
  final SupabaseClient sb;

  Future<Map<String, dynamic>> awardTripXp({
    required String tripId,
    required String userId,
    required int baseXp,
    required DateTime tripStart,
  }) async {
    // DEV MODE: Return mock XP result
    if (kUseDevMode) {
      return {
        'total_xp': baseXp * 2,
        'base_xp': baseXp,
        'multiplier': 2.0,
        'bonus_xp': baseXp,
        'source': 'trip_completion',
      };
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.awardTripXp,
      params: {
        'p_trip_id': tripId,
        'p_user_id': userId,
        'p_base_xp': baseXp,
        'p_trip_start': tripStart.toUtc().toIso8601String(),
      },
    );
    return res;
  }

  Stream<List<Map<String, dynamic>>> watchXpEvents(String userId) {
    if (kUseDevMode) {
      return Stream.value([
        {
          'id': 'xp_1',
          'user_id': userId,
          'source': 'trip_completion',
          'total_xp': 150,
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
        {
          'id': 'xp_2',
          'user_id': userId,
          'source': 'peak_hour_bonus',
          'total_xp': 75,
          'created_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
      ]);
    }
    return sb
        .from(DbTable.xpEvents)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
