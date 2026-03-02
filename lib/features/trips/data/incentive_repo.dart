import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/trips/domain/area_incentive.dart';
import 'package:khawi_flutter/state/providers.dart';

class IncentiveRepo {
  final SupabaseClient _sb;

  IncentiveRepo(this._sb);

  Future<List<AreaIncentive>> getIncentives(
    List<String> neighborhoodIds,
  ) async {
    if (neighborhoodIds.isEmpty) return [];

    // DEV MODE: Return mock incentives
    if (kUseDevMode) {
      return [
        AreaIncentive(
          areaKey: 'riyadh_central',
          timeBucket: DateTime.now().toIso8601String(),
          multiplier: 2.0,
          reasonTag: 'demand_high',
          computedAt: DateTime.now(),
          meta: {'surge_level': 'high', 'demand_count': 15},
        ),
        AreaIncentive(
          areaKey: 'riyadh_north',
          timeBucket: DateTime.now().toIso8601String(),
          multiplier: 1.5,
          reasonTag: 'demand_high',
          computedAt: DateTime.now(),
          meta: {'surge_level': 'medium', 'demand_count': 8},
        ),
      ];
    }

    try {
      // Canonical logic: bucket is hourly ISO string
      final now = DateTime.now().toUtc();
      final bucketTime = DateTime.utc(now.year, now.month, now.day, now.hour);
      final bucketStr = bucketTime.toIso8601String();

      final data = await _sb
          .from(DbTable.areaIncentives)
          .select()
          .inFilter('area_id', neighborhoodIds)
          .lte('time_bucket', bucketStr)
          .order('time_bucket', ascending: false)
          .limit(neighborhoodIds.length * 2);

      // Deduplicate by area_id, taking latest
      final incentives = <String, AreaIncentive>{};
      for (final row in data) {
        final areaId = row['area_id'] as String;
        if (!incentives.containsKey(areaId)) {
          incentives[areaId] = AreaIncentive.fromJson(row);
        }
      }
      return incentives.values.toList();
    } catch (e) {
      return [];
    }
  }
}
