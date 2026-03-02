import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/gamification/domain/mission.dart';

/// Repository for mission CRUD and progress tracking.
class MissionRepo {
  MissionRepo(this._client);
  final SupabaseClient _client;

  static const _table = DbTable.userMissions;

  /// Fetch active missions for [userId] in the current week.
  Future<List<Mission>> getActiveMissions(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .lte('week_start', now)
          .gte('week_end', now)
          .order('created_at');

      return data.map((e) => Mission.fromJson(e)).toList();
    } catch (e) {
      debugPrint('MissionRepo.getActiveMissions failed: $e');
      return [];
    }
  }

  /// Watch active missions via realtime stream.
  Stream<List<Mission>> watchActiveMissions(String userId) {
    try {
      return _client
          .from(_table)
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((rows) => rows.map((e) => Mission.fromJson(e)).toList());
    } catch (e) {
      debugPrint('MissionRepo.watchActiveMissions failed: $e');
      return Stream.value([]);
    }
  }
}
