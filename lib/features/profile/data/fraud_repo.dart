import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';

class FraudRepo {
  final SupabaseClient _sb;

  FraudRepo(this._sb);

  Future<bool> isThrottled() async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final data = await _sb
          .from(DbTable.profiles)
          .select('xp_throttle, xp_throttle_until')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return false;

      final isThrottled = data['xp_throttle'] as bool? ?? false;
      final untilStr = data['xp_throttle_until'] as String?;

      if (!isThrottled) return false;
      if (untilStr == null) return true; // Throttled indefinitely if no date

      final until = DateTime.parse(untilStr);
      return DateTime.now().isBefore(until);
    } catch (e) {
      return false;
    }
  }
}
