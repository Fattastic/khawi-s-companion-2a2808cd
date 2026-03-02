import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardChallenge {
  final String id;
  final String title;
  final String description;
  final double progress;
  final String reward;

  RewardChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.reward,
  });
}

class RewardsRepo {
  final SupabaseClient _sb;
  RewardsRepo(this._sb);

  /// Attempt to redeem a reward by inserting into `reward_redemptions`.
  /// If the server rejects due to RLS (non-premium), this surfaces a [PremiumRequiredException].
  Future<void> attemptRedeem({
    required String userId,
    required String rewardId,
    required int xpCost,
  }) async {
    try {
      await _sb.from(DbTable.rewardRedemptions).insert({
        'user_id': userId,
        'reward_id': rewardId,
        'xp_cost': xpCost,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw PremiumRequiredException();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RewardChallenge>> getActiveChallenges() async {
    try {
      // Fetch xp_rules configured as challenges
      final res = await _sb
          .from(DbTable.xpRules)
          .select()
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      final userId = _sb.auth.currentUser?.id;
      if (userId == null) return [];

      // Fetch user's recent XP events to calculate progress
      final xpEvents = await _sb
          .from(DbTable.xpEvents)
          .select('source, amount')
          .eq('user_id', userId)
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          );

      return (res as List).map((rule) {
        final config = rule['config'] as Map<String, dynamic>? ?? {};
        final ruleKey = rule['rule_key'] as String? ?? '';

        // Calculate progress based on rule type
        double progress = 0.0;
        if (config['target_count'] != null) {
          final targetCount = (config['target_count'] as num).toInt();
          final completedCount =
              xpEvents.where((e) => e['source'] == ruleKey).length;
          progress = (completedCount / targetCount).clamp(0.0, 1.0);
        }

        return RewardChallenge(
          id: rule['id'] as String,
          title: config['title'] as String? ?? ruleKey,
          description: config['description'] as String? ??
              'Complete this challenge to earn XP',
          progress: progress,
          reward: '${config['xp_reward'] ?? 100} XP',
        );
      }).toList();
    } catch (e) {
      // Return default challenges if xp_rules table is empty
      return [
        RewardChallenge(
          id: 'early_bird',
          title: 'The Early Bird',
          description: 'Complete 3 rides before 9 AM',
          progress: 0.0,
          reward: '150 XP',
        ),
        RewardChallenge(
          id: 'eco_warrior',
          title: 'Eco Warrior',
          description: 'Share a ride with 3+ passengers',
          progress: 0.0,
          reward: '300 XP',
        ),
      ];
    }
  }
}

class PremiumRequiredException implements Exception {
  @override
  String toString() => 'Premium required to redeem this reward.';
}
