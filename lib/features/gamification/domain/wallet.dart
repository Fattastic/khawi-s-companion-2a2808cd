import 'gamification_enums.dart';

/// Summary of a user's value wallet.
class WalletSummary {
  const WalletSummary({
    required this.userId,
    required this.earnedTotal,
    required this.unlockedTotal,
    required this.pendingTotal,
    required this.redeemedTotal,
    required this.updatedAt,
  });

  final String userId;
  final int earnedTotal;
  final int unlockedTotal;
  final int pendingTotal;
  final int redeemedTotal;
  final DateTime updatedAt;

  /// Net available balance (unlocked minus redeemed).
  int get availableBalance => unlockedTotal - redeemedTotal;

  factory WalletSummary.empty(String userId) => WalletSummary(
        userId: userId,
        earnedTotal: 0,
        unlockedTotal: 0,
        pendingTotal: 0,
        redeemedTotal: 0,
        updatedAt: DateTime.now(),
      );

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
        userId: json['user_id'] as String,
        // DB columns are total_* (not *_total)
        earnedTotal:
            (json['total_earned'] ?? json['earned_total']) as int? ?? 0,
        unlockedTotal:
            (json['total_unlocked'] ?? json['unlocked_total']) as int? ?? 0,
        pendingTotal:
            (json['total_pending'] ?? json['pending_total']) as int? ?? 0,
        redeemedTotal:
            (json['total_redeemed'] ?? json['redeemed_total']) as int? ?? 0,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
}

/// Single wallet transaction entry for history display.
///
/// The DB `wallet_transactions` table stores `type` as 'credit' | 'debit'.
/// A credit maps to an `earned` WalletValueState; a debit maps to `redeemed`.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.reason,
    required this.createdAt,
    this.referenceId,
  });

  final String id;
  final String userId;

  /// Raw amount — always positive in DB; sign determined by [type].
  final int amount;

  /// 'credit' or 'debit'.
  final String type;
  final String reason;
  final DateTime createdAt;
  final String? referenceId;

  /// Signed amount: positive for credits, negative for debits.
  int get signedAmount => type == 'debit' ? -amount : amount;

  /// Derived WalletValueState for display purposes.
  WalletValueState get walletState =>
      type == 'debit' ? WalletValueState.redeemed : WalletValueState.earned;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        amount: (json['amount'] as num?)?.abs().toInt() ?? 0,
        // DB stores 'credit' or 'debit'; legacy data may have WalletValueState keys
        type: _normaliseType(
            json['type'] as String? ?? json['state'] as String? ?? 'credit',),
        reason: json['reason'] as String? ?? '',
        referenceId: json['reference_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  /// Normalises legacy WalletValueState keys to credit/debit.
  static String _normaliseType(String raw) {
    switch (raw) {
      case 'debit':
      case 'redeemed':
        return 'debit';
      default:
        return 'credit';
    }
  }
}
