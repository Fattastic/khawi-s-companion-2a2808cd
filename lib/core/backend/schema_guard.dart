import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';

/// Defines expected columns for each table used by the app.
const Map<String, List<String>> kExpectedTableColumns = {
  DbTable.trips: [
    DbCol.id,
    DbCol.driverId,
    DbCol.originLat,
    DbCol.originLng,
    DbCol.destLat,
    DbCol.destLng,
    DbCol.originLabel,
    DbCol.destLabel,
    DbCol.polyline,
    DbCol.departureTime,
    DbCol.isRecurring,
    DbCol.scheduleJson,
    DbCol.seatsTotal,
    DbCol.seatsAvailable,
    DbCol.womenOnly,
    DbCol.isKidsRide,
    DbCol.tags,
    DbCol.status,
    DbCol.neighborhoodId,
  ],

  // Add other tables and their expected columns here
  // Check 'profiles' instead of 'users' (which is in auth schema)
  DbTable.profiles: [
    DbCol.id,
    DbCol.fullName,
    DbCol.avatarUrl,
    DbCol.role,
    DbCol.isPremium,
    DbCol.isVerified,
    DbCol.totalXp,
    DbCol.redeemableXp,
    DbCol.gender,
    DbCol.neighborhoodId,
    DbCol.xpThrottle,
    DbCol.xpThrottleUntil,
  ],
  DbTable.juniorRuns: [
    DbCol.id,
    DbCol.kidId,
    DbCol.parentId,
    DbCol.assignedDriverId,
    DbCol.status,
    DbCol.pickupLat,
    DbCol.pickupLng,
    DbCol.dropoffLat,
    DbCol.dropoffLng,
    DbCol.pickupTime,
  ],
};

/// Runs a debug-only schema check for all expected tables/columns.
Future<List<String>> performSchemaGuard(SupabaseClient sb) async {
  if (!kDebugMode) return [];
  final List<String> errors = [];
  for (final entry in kExpectedTableColumns.entries) {
    final table = entry.key;
    final expected = entry.value;
    try {
      final resp = await sb.from(table).select().limit(1).maybeSingle();
      if (resp == null) continue; // Table empty, can't check
      for (final col in expected) {
        if (!resp.containsKey(col)) {
          errors.add('Table "$table" missing column: $col');
        }
      }
    } catch (e) {
      // 406/Not Acceptable or 404/Not Found often means RLS blocks access or table empty.
      // Don't treat as critical schema failure.
      if (e.toString().contains('PGRST') ||
          e.toString().contains('404') ||
          e.toString().contains('406')) {
        debugPrint('SchemaGuard: Skipped "$table" (RLS/Access Restricted)');
      } else {
        errors.add(
          'Table "$table" error: $e. (Try running "supabase db reset" locally)',
        );
      }
    }
  }
  return errors;
}
