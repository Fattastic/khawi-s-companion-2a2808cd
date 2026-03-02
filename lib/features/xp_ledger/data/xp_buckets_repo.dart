import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/features/xp_ledger/domain/xp_buckets.dart';

/// Repository for XP bucket operations.
class XpBucketsRepo {
  final SupabaseClient _sb;
  XpBucketsRepo(this._sb);

  /// Fetches XP buckets for a user.
  Future<XpBuckets> getBuckets(String userId) async {
    final data = await _sb
        .from('xp_buckets')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      return XpBuckets.empty();
    }

    return XpBuckets.fromJson(data);
  }

  /// Watches XP buckets in real-time.
  Stream<XpBuckets> watchBuckets(String userId) {
    return _sb
        .from('xp_buckets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) {
          if (data.isEmpty) return XpBuckets.empty();
          return XpBuckets.fromJson(data.first);
        });
  }

  /// Classifies XP into appropriate bucket (calls Edge Function).
  Future<void> classifyXp({
    required String userId,
    required String source,
    required int amount,
  }) async {
    await _sb.functions.invoke(
      'classify_xp_bucket',
      body: {
        'userId': userId,
        'source': source,
        'amount': amount,
      },
    );
  }
}

final xpBucketsRepoProvider =
    Provider((ref) => XpBucketsRepo(Supabase.instance.client));

final xpBucketsProvider =
    StreamProvider.family<XpBuckets, String>((ref, userId) {
  return ref.watch(xpBucketsRepoProvider).watchBuckets(userId);
});
