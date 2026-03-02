import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/backend/backend_contract.dart';

class SubscriptionRepo {
  final SupabaseClient _sb;

  SubscriptionRepo(this._sb);

  /// Get current subscription status for the user
  Future<String> getSubscriptionStatus(String userId) async {
    final response = await _sb
        .from(DbTable.profiles)
        .select(DbCol.subscriptionStatus)
        .eq(DbCol.id, userId)
        .single();
    return response[DbCol.subscriptionStatus] as String? ?? 'inactive';
  }

  /// Create a Stripe checkout session for a specific price ID
  Future<String?> createCheckoutSession(String priceId) async {
    try {
      final response = await _sb.functions.invoke(
        EdgeFn.createCheckoutSession,
        body: {'priceId': priceId},
      );

      if (response.data != null && response.data['url'] != null) {
        return response.data['url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final subscriptionRepoProvider = Provider<SubscriptionRepo>((ref) {
  return SubscriptionRepo(Supabase.instance.client);
});
