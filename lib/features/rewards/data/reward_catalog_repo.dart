import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/features/rewards/domain/reward_item.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';
import 'package:khawi_flutter/features/rewards/data/rewards_repo.dart'
    show PremiumRequiredException;

/// Repository for the reward catalog and redemption.
class RewardCatalogRepo {
  final SupabaseClient _sb;
  RewardCatalogRepo(this._sb);

  /// Fetches all active rewards from the catalog.
  Future<List<RewardItem>> getAllRewards() async {
    final data = await _sb
        .from('reward_catalog')
        .select()
        .eq('is_active', true)
        .order('xp_cost', ascending: true);

    return (data as List)
        .map((e) => RewardItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches rewards available to user based on trust tier.
  Future<List<RewardItem>> getAvailableRewards({
    required String userId,
    required TrustTier userTier,
    required bool isPremium,
  }) async {
    final all = await getAllRewards();

    return all.where((r) {
      // Check tier requirement
      if (!userTier.isAtLeast(r.trustTierRequired)) return false;

      // Check subscription requirement
      if (r.subscriptionRequired && !isPremium) return false;

      return true;
    }).toList();
  }

  /// Attempts to redeem a reward with tier and cap validation.
  Future<void> attemptRedemption({
    required String userId,
    required String rewardId,
    required int xpCost,
    required TrustTier userTier,
    required bool isPremium,
  }) async {
    // Fetch reward details
    final rewardData =
        await _sb.from('reward_catalog').select().eq('id', rewardId).single();

    final reward = RewardItem.fromJson(rewardData);

    // Validate tier
    if (!userTier.isAtLeast(reward.trustTierRequired)) {
      throw TrustTierRequiredException(reward.trustTierRequired);
    }

    // Validate subscription for partner rewards
    if (reward.subscriptionRequired && !isPremium) {
      throw PremiumRequiredException();
    }

    // Check weekly cap
    if (reward.weeklyCap != null) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final redemptions = await _sb
          .from('reward_redemption_log')
          .select('id')
          .eq('user_id', userId)
          .eq('reward_id', rewardId)
          .gte('redeemed_at', weekAgo.toIso8601String());

      if ((redemptions as List).length >= reward.weeklyCap!) {
        throw RedemptionCapExceededException(reward.weeklyCap!);
      }
    }

    // Log redemption
    await _sb.from('reward_redemption_log').insert({
      'user_id': userId,
      'reward_id': rewardId,
      'xp_spent': xpCost,
    });

    // Deduct XP via Edge Function
    await _sb.functions.invoke(
      'redeem_reward',
      body: {
        'user_id': userId,
        'reward_id': rewardId,
        'xp_cost': xpCost,
      },
    );
  }

  /// Gets redemption count for a reward this week.
  Future<int> getWeeklyRedemptionCount(String userId, String rewardId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final data = await _sb
        .from('reward_redemption_log')
        .select('id')
        .eq('user_id', userId)
        .eq('reward_id', rewardId)
        .gte('redeemed_at', weekAgo.toIso8601String());

    return (data as List).length;
  }
}

/// Thrown when user's trust tier is insufficient for a reward.
class TrustTierRequiredException implements Exception {
  final TrustTier required;
  TrustTierRequiredException(this.required);

  @override
  String toString() => 'Trust tier ${required.displayName} required.';
}

/// Thrown when weekly redemption cap is exceeded.
class RedemptionCapExceededException implements Exception {
  final int cap;
  RedemptionCapExceededException(this.cap);

  @override
  String toString() => 'Weekly redemption limit ($cap) exceeded.';
}

final rewardCatalogRepoProvider =
    Provider((ref) => RewardCatalogRepo(Supabase.instance.client));

final availableRewardsProvider = FutureProvider.family<List<RewardItem>,
    ({String userId, TrustTier tier, bool isPremium})>((ref, params) {
  return ref.watch(rewardCatalogRepoProvider).getAvailableRewards(
        userId: params.userId,
        userTier: params.tier,
        isPremium: params.isPremium,
      );
});
