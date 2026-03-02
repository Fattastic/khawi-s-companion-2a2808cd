import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/data/dto/edge/demand_point_dto.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/network/retry_utils.dart';

class DemandRepo {
  final SupabaseClient _sb;

  DemandRepo(this._sb);

  Future<List<DemandPoint>> fetchDemandForecast(double lat, double lng) async {
    // DEV MODE: Return mock demand points around the current location
    if (kUseDevMode) {
      return [
        const DemandPoint(
          lat: 24.7136,
          lng: 46.6753,
          intensity: 0.9,
          label: 'High Demand: Olaya',
        ),
        const DemandPoint(
          lat: 24.7001,
          lng: 46.6853,
          intensity: 0.7,
          label: 'Medium Demand: Tahlia',
        ),
        const DemandPoint(
          lat: 24.7236,
          lng: 46.6553,
          intensity: 0.85,
          label: 'High Demand: Riyadh Park',
        ),
        const DemandPoint(
          lat: 24.7336,
          lng: 46.6653,
          intensity: 0.6,
          label: 'Stable Demand: Digital City',
        ),
      ];
    }

    try {
      final response = await RetryUtils.retry(
        () => _sb.functions.invoke(
          EdgeFn.predictDemand,
          body: {'lat': lat, 'lng': lng},
        ),
        retryIf: RetryUtils.shouldRetrySupabaseError,
      );

      if (response.data == null) return [];

      final data = response.data as Map<String, dynamic>;
      final pointsData = data['points'] as List<dynamic>;
      return pointsData
          .map((p) => DemandPoint.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

final demandRepoProvider = Provider<DemandRepo>((ref) {
  return DemandRepo(ref.watch(supabaseClientProvider));
});
