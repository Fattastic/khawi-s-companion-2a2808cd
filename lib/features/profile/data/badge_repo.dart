import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/features/profile/domain/user_badge.dart';

/// Repository for user badges.
class BadgeRepo {
  final SupabaseClient _sb;
  BadgeRepo(this._sb);

  /// Fetches all active badges for a user.
  Future<List<UserBadge>> getUserBadges(String userId) async {
    final data = await _sb
        .from('user_badges')
        .select('*, badges(*)')
        .eq('user_id', userId)
        .isFilter('revoked_at', null)
        .order('earned_at', ascending: false);

    return (data as List)
        .map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Watches user badges in real-time.
  Stream<List<UserBadge>> watchBadges(String userId) {
    return _sb
        .from('user_badges')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (data) => data
              .where((e) => e['revoked_at'] == null)
              .map((e) => UserBadge.fromJson(e))
              .toList(),
        );
  }

  /// Checks if user has a specific badge.
  Future<bool> hasBadge(String userId, String badgeKey) async {
    final data = await _sb
        .from('user_badges')
        .select('id, badges!inner(key)')
        .eq('user_id', userId)
        .eq('badges.key', badgeKey)
        .isFilter('revoked_at', null)
        .maybeSingle();

    return data != null;
  }

  /// Triggers badge evaluation for a user (calls Edge Function).
  Future<Map<String, dynamic>> evaluateBadges(String userId) async {
    final res = await _sb.functions.invoke(
      'evaluate_badges',
      body: {'userId': userId},
    );
    return res.data as Map<String, dynamic>;
  }
}

final badgeRepoProvider =
    Provider((ref) => BadgeRepo(Supabase.instance.client));

final userBadgesProvider =
    FutureProvider.family<List<UserBadge>, String>((ref, userId) {
  return ref.watch(badgeRepoProvider).getUserBadges(userId);
});
