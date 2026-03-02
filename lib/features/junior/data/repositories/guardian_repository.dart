import 'package:supabase_flutter/supabase_flutter.dart';

class GuardianRepository {
  final SupabaseClient _sb;

  GuardianRepository(this._sb);

  /// Check if a user is an authorized guardian for a junior
  Future<bool> isGuardianOf(String guardianId, String juniorId) async {
    final response = await _sb
        .from('family_relationships')
        .select()
        .eq('guardian_id', guardianId)
        .eq('junior_id', juniorId)
        .maybeSingle();
    return response != null;
  }

  /// Add a driver to the guardian's trusted whitelist
  Future<void> whitelistDriver(String guardianId, String driverId) async {
    await _sb.from('trusted_drivers').upsert({
      'guardian_id': guardianId,
      'driver_id': driverId,
      'is_whitelisted': true,
    });
  }

  /// Check if a driver is whitelisted by a guardian
  Future<bool> isDriverWhitelisted(String guardianId, String driverId) async {
    final response = await _sb
        .from('trusted_drivers')
        .select()
        .eq('guardian_id', guardianId)
        .eq('driver_id', driverId)
        .eq('is_whitelisted', true)
        .maybeSingle();
    return response != null;
  }
}
