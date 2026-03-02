import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/xp_ledger/domain/xp_transaction.dart';
import 'package:khawi_flutter/features/rewards/data/rewards_repo.dart'
    show PremiumRequiredException;
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;

/// Repository for XP transactions and redemption (formerly XpLedgerRepo).
class XpLedgerRepo {
  final SupabaseClient _client;
  XpLedgerRepo(this._client);

  Stream<List<XpTransaction>> watchTransactions() {
    // Return mock data in dev mode
    if (kUseDevMode) {
      return Stream.value([
        XpTransaction(
          id: 'tx_1',
          userId: 'dev_user_id',
          title: 'TRIP COMPLETION',
          amount: '+150 XP',
          type: 'credit',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        XpTransaction(
          id: 'tx_2',
          userId: 'dev_user_id',
          title: 'PEAK HOUR BONUS',
          amount: '+75 XP',
          type: 'credit',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        XpTransaction(
          id: 'tx_3',
          userId: 'dev_user_id',
          title: 'SYNERGY BONUS',
          amount: '+50 XP',
          type: 'credit',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        XpTransaction(
          id: 'tx_4',
          userId: 'dev_user_id',
          title: 'REFERRAL REWARD',
          amount: '+300 XP',
          type: 'credit',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        XpTransaction(
          id: 'tx_5',
          userId: 'dev_user_id',
          title: 'REWARD REDEMPTION',
          amount: '-100 XP',
          type: 'debit',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        XpTransaction(
          id: 'tx_6',
          userId: 'dev_user_id',
          title: 'SYNERGY BONUS',
          amount: '-100 XP',
          type: 'debit',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ]);
    }

    return _client
        .from(DbTable.xpEvents)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map(
          (data) => data
              .map(
                (json) => XpTransaction(
                  id: json['id'] as String,
                  userId: json['user_id'] as String,
                  title: json['source']
                      .toString()
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  amount: "${json['total_xp']} XP",
                  type: (json['total_xp'] as num) >= 0 ? 'credit' : 'debit',
                  createdAt: DateTime.parse(json['created_at'] as String),
                ),
              )
              .toList(),
        );
  }

  Future<void> redeemXp(int amount, {String rewardId = 'xp_cash_out'}) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be > 0');
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not authenticated');

    // Use server-side RPC for premium enforcement
    // This ensures premium check cannot be bypassed by calling API directly
    final result = await _client.rpc<Map<String, dynamic>>(
      DbRpc.redeemXpPremium,
      params: {
        'p_amount': amount,
        'p_reward_id': rewardId,
      },
    );

    final response = result;
    final success = response['success'] as bool? ?? false;

    if (!success) {
      final error = response['error'] as String? ?? 'unknown';
      final message = response['message'] as String? ?? 'Redemption failed';

      // Map server errors to appropriate exceptions
      switch (error) {
        case 'premium_required':
          throw PremiumRequiredException();
        case 'insufficient_balance':
          throw StateError('Not enough redeemable XP');
        case 'not_authenticated':
          throw StateError('Not authenticated');
        case 'invalid_amount':
          throw ArgumentError.value(amount, 'amount', message);
        default:
          throw StateError(message);
      }
    }

    // Success - the RPC handles all XP deduction and audit logging
  }

  Future<Map<String, dynamic>> calculateTripXp({
    required String tripId,
    required String role,
    required double distanceKm,
    int? passengerCount,
    bool? isPeakHour,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not authenticated');

    final res = await _client.functions.invoke(
      'xp_calculate',
      body: {
        'userId': uid,
        'tripId': tripId,
        'role': role,
        'distanceKm': distanceKm,
        if (passengerCount != null) 'passengerCount': passengerCount,
        if (isPeakHour != null) 'isPeakHour': isPeakHour,
      },
    );

    return res.data as Map<String, dynamic>;
  }
}

final xpLedgerRepoProvider =
    Provider((ref) => XpLedgerRepo(Supabase.instance.client));

final xpTransactionsProvider = StreamProvider<List<XpTransaction>>((ref) {
  return ref.watch(xpLedgerRepoProvider).watchTransactions();
});
