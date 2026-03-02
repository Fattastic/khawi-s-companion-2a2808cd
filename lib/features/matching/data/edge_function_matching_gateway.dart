import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

/// Production implementation of [MatchingGateway] using Supabase Edge Functions.
///
/// Calls the deployed AI matching edge functions:
/// - `score_matches` for trip scoring
/// - `bundle_stops` for route optimization
class EdgeFunctionMatchingGateway implements MatchingGateway {
  EdgeFunctionMatchingGateway(this._sb);
  final SupabaseClient _sb;

  @override
  Future<List<Match>> smartMatch(MatchRequest request) async {
    try {
      final response = await _sb.functions.invoke(
        EdgeFn.smartMatch,
        body: {
          'origin': {'lat': request.originLat, 'lng': request.originLng},
          'destination': {'lat': request.destLat, 'lng': request.destLng},
          if (request.departureTime != null)
            'departure_time': request.departureTime!.toIso8601String(),
          if (request.womenOnly != null) 'women_only': request.womenOnly,
          'max_results': request.maxResults,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const MatchingException('Malformed response from smart_match');
      }

      final matchesJson = data['matches'] as List?;
      if (matchesJson == null) {
        return [];
      }

      return matchesJson.map((json) {
        final tripJson = json['trip'] as Map<String, dynamic>;
        return Match(
          trip: Trip.fromJson(tripJson),
          score: (json['score'] as num).toInt(),
          explanationTags: (json['tags'] as List?)?.cast<String>() ?? [],
          acceptProbability: (json['accept_prob'] as num?)?.toDouble() ?? 0.0,
          etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
        );
      }).toList();
    } on FunctionException catch (e) {
      debugPrint('EdgeFunctionMatchingGateway.smartMatch error: $e');
      if (e.status == 404) return [];
      if (e.status == 401 || e.status == 403) {
        throw const MatchingException('Unauthorized');
      }
      throw MatchingException(e.reasonPhrase ?? e.toString());
    } catch (e) {
      debugPrint('EdgeFunctionMatchingGateway.smartMatch error: $e');
      if (e is MatchingException) rethrow;
      throw MatchingException(e.toString());
    }
  }

  @override
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

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final suggestion = data[EdgeRes.suggestion] as Map<String, dynamic>?;
      if (suggestion == null) return null;

      final stopsJson = suggestion[EdgeRes.stops] as List?;
      return BundleResult(
        rankScore: (suggestion[EdgeRes.rankScore] as num?)?.toInt() ?? 0,
        stops: stopsJson
                ?.map((s) => BundleStop.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('EdgeFunctionMatchingGateway.bundleStops error: $e');
      return null;
    }
  }

  @override
  Future<Map<String, Match>> scoreTrips({
    required List<Trip> trips,
    required MatchRequest request,
  }) async {
    if (trips.isEmpty) return {};

    try {
      final response = await _sb.functions.invoke(
        EdgeFn.scoreMatches,
        body: {
          'trip_ids': trips.map((t) => t.id).toList(),
          'passenger_origin': {
            'lat': request.originLat,
            'lng': request.originLng,
          },
          'passenger_dest': {'lat': request.destLat, 'lng': request.destLng},
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const MatchingException('Malformed response from score_matches');
      }

      final matchesJson = data['matches'] as List?;
      if (matchesJson == null) return {};

      final tripMap = {for (final t in trips) t.id: t};
      final result = <String, Match>{};

      for (final json in matchesJson) {
        final tripId = json['trip_id'] as String;
        final trip = tripMap[tripId];
        if (trip == null) continue;

        result[tripId] = Match(
          trip: trip,
          score: (json['match_score'] as num).toInt(),
          explanationTags:
              (json['explanation_tags'] as List?)?.cast<String>() ?? [],
          acceptProbability: (json['accept_prob'] as num?)?.toDouble() ?? 0.0,
          etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
        );
      }

      return result;
    } on FunctionException catch (e) {
      debugPrint('EdgeFunctionMatchingGateway.scoreTrips error: $e');
      if (e.status == 404) return {};
      if (e.status == 401 || e.status == 403) {
        throw const MatchingException('Unauthorized');
      }
      throw MatchingException(e.reasonPhrase ?? e.toString());
    } catch (e) {
      debugPrint('EdgeFunctionMatchingGateway.scoreTrips error: $e');
      if (e is MatchingException) rethrow;
      throw MatchingException(e.toString());
    }
  }
}
