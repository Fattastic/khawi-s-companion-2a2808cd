import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/gamification/domain/wallet.dart';

/// Repository for value wallet summary and transaction history.
class WalletRepo {
  WalletRepo(this._client);
  final SupabaseClient _client;

  static const _summaryTable = DbTable.userWalletSummary;
  static const _txTable = DbTable.walletTransactions;

  /// Fetch wallet summary for [userId].
  Future<WalletSummary> getSummary(String userId) async {
    try {
      final data = await _client
          .from(_summaryTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return WalletSummary.empty(userId);
      return WalletSummary.fromJson(data);
    } catch (e) {
      debugPrint('WalletRepo.getSummary failed: $e');
      return WalletSummary.empty(userId);
    }
  }

  /// Fetch paginated wallet transaction history.
  Future<List<WalletTransaction>> getHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from(_txTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return data.map((e) => WalletTransaction.fromJson(e)).toList();
    } catch (e) {
      debugPrint('WalletRepo.getHistory failed: $e');
      return [];
    }
  }

  /// Watch wallet summary via realtime.
  Stream<WalletSummary> watchSummary(String userId) {
    try {
      return _client
          .from(_summaryTable)
          .stream(primaryKey: ['user_id'])
          .eq('user_id', userId)
          .map((rows) {
            if (rows.isEmpty) return WalletSummary.empty(userId);
            return WalletSummary.fromJson(rows.first);
          });
    } catch (e) {
      debugPrint('WalletRepo.watchSummary failed: $e');
      return Stream.value(WalletSummary.empty(userId));
    }
  }
}
