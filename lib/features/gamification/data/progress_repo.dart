import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/gamification/domain/next_best_action.dart';
import 'package:khawi_flutter/features/gamification/domain/progress_snapshot.dart';

/// Repository for fetching unified progress snapshots and next-best-action recommendations.
class ProgressRepo {
  ProgressRepo(this._client);
  final SupabaseClient _client;

  /// Fetch a unified read-only progress snapshot for [userId] and [role].
  ///
  /// This calls a Supabase Edge Function that assembles streak, missions,
  /// wallet, and NBA data into a single response.
  Future<ProgressSnapshot> getSnapshot({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _client.functions.invoke(
        EdgeFn.getProgressSnapshot,
        body: {'user_id': userId, 'role': role},
      );

      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      return ProgressSnapshot.fromJson(data);
    } catch (e) {
      debugPrint('ProgressRepo.getSnapshot failed: $e');
      return ProgressSnapshot.empty(userId);
    }
  }

  /// Fetch a single next-best-action recommendation.
  Future<NextBestAction?> getNextAction({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _client.functions.invoke(
        EdgeFn.getNextAction,
        body: {'user_id': userId, 'role': role},
      );

      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      if (data.isEmpty) return null;
      return NextBestAction.fromJson(data);
    } catch (e) {
      debugPrint('ProgressRepo.getNextAction failed: $e');
      return null;
    }
  }
}
