import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/data/dto/edge/check_trip_safety_dto.dart';

class SafetyService {
  final SupabaseClient _sb = Supabase.instance.client;

  Future<CheckTripSafetyResponse?> checkTripSafety(
    CheckTripSafetyRequest req,
  ) async {
    try {
      final res = await _sb.functions
          .invoke(EdgeFn.checkTripSafety, body: req.toJson());
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return CheckTripSafetyResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createSos({
    required String tripId,
    required double lat,
    required double lng,
    required String message,
    int severity = 5,
  }) async {
    await _sb.rpc<void>(
      DbRpc.createSos,
      params: {
        'p_trip_id': tripId,
        'p_kind': 'sos',
        'p_severity': severity,
        'p_lat': lat,
        'p_lng': lng,
        'p_message': message,
      },
    );
  }
}
