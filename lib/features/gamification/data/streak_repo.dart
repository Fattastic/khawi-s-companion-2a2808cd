import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/gamification/domain/streak_state.dart';

/// Repository for streak read/write operations.
class StreakRepo {
  StreakRepo(this._client);
  final SupabaseClient _client;

  static const _table = DbTable.userStreaks;

  /// Fetch current streak state for [userId].
  Future<StreakState> getStreak(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return StreakState.empty(userId);
      return StreakState.fromJson(data);
    } catch (e) {
      debugPrint('StreakRepo.getStreak failed: $e');
      return StreakState.empty(userId);
    }
  }

  /// Watch streak state via realtime stream.
  Stream<StreakState> watchStreak(String userId) {
    try {
      return _client
          .from(_table)
          .stream(primaryKey: ['user_id'])
          .eq('user_id', userId)
          .map((rows) {
            if (rows.isEmpty) return StreakState.empty(userId);
            return StreakState.fromJson(rows.first);
          });
    } catch (e) {
      debugPrint('StreakRepo.watchStreak failed: $e');
      return Stream.value(StreakState.empty(userId));
    }
  }
}
