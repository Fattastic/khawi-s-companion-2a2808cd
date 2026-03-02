import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/data/dto/edge/score_matches_dto.dart';

class MatchService {
  final SupabaseClient _sb;

  MatchService(this._sb);

  Future<Map<String, ScoreMatch>> scoreTrips({
    required List<Trip> trips,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    List<String> passengerPreferences = const [],
  }) async {
    if (trips.isEmpty) return {};
    try {
      final req = ScoreMatchesRequest(
        tripIds: trips.map((t) => t.id).toList(),
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        passengerPreferences: passengerPreferences,
      );
      final response = await _sb.functions.invoke(
        EdgeFn.scoreMatches,
        body: req.toJson(),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ScoreMatchesFailure('Malformed response');
      }
      final matchesResp = ScoreMatchesResponse.fromJson(data);
      return {for (final m in matchesResp.matches) m.tripId: m};
    } catch (e) {
      debugPrint('Error calling score_matches: $e');
      throw ScoreMatchesFailure(e.toString());
    }
  }

  Future<BundleResult?> bundleStops({
    required String tripId,
    required List<String> passengerIds,
  }) async {
    try {
      final response = await _sb.functions.invoke(
        EdgeFn.bundleStops,
        body: {
          'trip_id': tripId,
          'passenger_ids': passengerIds,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final suggestion = data[EdgeRes.suggestion] as Map<String, dynamic>?;

      if (suggestion != null) {
        return BundleResult(
          rankScore: suggestion[EdgeRes.rankScore] as int,
          stops: (suggestion[EdgeRes.stops] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error calling bundle_stops: $e');
      return null;
    }
  }
}

class BundleResult {
  final int rankScore;
  final List<Map<String, dynamic>> stops;

  BundleResult({required this.rankScore, required this.stops});
}

class TripScore {
  final int score;
  final List<String> tags;
  final double acceptProb;

  TripScore({
    required this.score,
    required this.tags,
    required this.acceptProb,
  });
}
