import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/profile/domain/trust_profile.dart';

class TrustRepo {
  final SupabaseClient _sb;

  TrustRepo(this._sb);

  Future<TrustProfile?> getTrustProfile(String userId) async {
    try {
      final data = await _sb
          .from(DbTable.trustProfiles)
          .select(
            'user_id, trust_score, trust_badge, junior_trusted, computed_at',
          )
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return TrustProfile.fromJson(data);
    } catch (e) {
      // Fail gracefully
      return null;
    }
  }
}
