import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/data/dto/edge/compute_incentives_dto.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/network/retry_utils.dart';

// KEEPING TripSearchQuery for Marketplace controller compatibility
class TripSearchQuery {
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final DateTime? earliestDeparture;
  final DateTime? latestDeparture;
  final bool? womenOnly;
  final String? neighborhoodId;
  final int? minSeats;

  const TripSearchQuery({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.earliestDeparture,
    this.latestDeparture,
    this.womenOnly,
    this.neighborhoodId,
    this.minSeats,
  });
}

class TripsRepo {
  TripsRepo(this.sb);
  final SupabaseClient sb;

  Stream<TripStatus> streamTripStatus(String tripId) {
    return sb
        .from(DbTable.trips)
        .stream(primaryKey: ['id'])
        .eq('id', tripId)
        .map((event) {
          if (event.isEmpty) return TripStatus.cancelled;
          final statusStr = event.first['status'] as String;
          return TripStatus.values.firstWhere(
            (e) => e.name == statusStr,
            orElse: () => TripStatus.planned,
          );
        });
  }

  // Mock trips for dev mode
  static List<Trip> get _mockTrips => [
        Trip(
          id: 'trip_1',
          driverId: 'driver_1',
          originLat: 24.7136,
          originLng: 46.6753,
          destLat: 24.7736,
          destLng: 46.7353,
          originLabel: 'Al Olaya District',
          destLabel: 'King Fahd Road',
          departureTime: DateTime.now().add(const Duration(hours: 1)),
          isRecurring: false,
          seatsTotal: 4,
          seatsAvailable: 3,
          womenOnly: false,
          isKidsRide: false,
          tags: ['morning_commute', 'express'],
          status: TripStatus.planned,
          matchScore: 92,
          driverTrustScore: 85,
          driverTrustBadge: 'gold',
        ),
        Trip(
          id: 'trip_2',
          driverId: 'driver_2',
          originLat: 24.6908,
          originLng: 46.6855,
          destLat: 24.7500,
          destLng: 46.7000,
          originLabel: 'Al Malaz',
          destLabel: 'Granada Center',
          departureTime: DateTime.now().add(const Duration(hours: 2)),
          isRecurring: true,
          seatsTotal: 3,
          seatsAvailable: 2,
          womenOnly: true,
          isKidsRide: false,
          tags: ['women_only', 'daily'],
          status: TripStatus.planned,
          matchScore: 85,
          driverTrustScore: 78,
          driverTrustBadge: 'silver',
        ),
        Trip(
          id: 'trip_3',
          driverId: 'driver_3',
          originLat: 24.7236,
          originLng: 46.6553,
          destLat: 24.8000,
          destLng: 46.7500,
          originLabel: 'Al Muruj',
          destLabel: 'Riyadh Park',
          departureTime: DateTime.now().add(const Duration(hours: 3)),
          isRecurring: false,
          seatsTotal: 4,
          seatsAvailable: 4,
          womenOnly: false,
          isKidsRide: true,
          tags: ['kids_ride', 'school'],
          status: TripStatus.planned,
          matchScore: 78,
          driverTrustScore: 90,
          driverTrustBadge: 'gold',
          driverJuniorTrusted: true,
        ),
      ];

  Stream<Trip> watchTrip(String tripId) {
    // DEV MODE: Return mock trip
    if (kUseDevMode) {
      final trip = _mockTrips.firstWhere(
        (t) => t.id == tripId,
        orElse: () => _mockTrips.first,
      );
      return Stream.value(trip);
    }
    return sb
        .from(DbTable.trips)
        .stream(primaryKey: ['id'])
        .eq('id', tripId)
        .map((rows) => Trip.fromJson(rows.first));
  }

  Stream<List<Trip>> watchMyTrips(String driverId) {
    // DEV MODE: Return mock trips
    if (kUseDevMode) {
      return Stream.value(_mockTrips);
    }
    return sb
        .from(DbTable.trips)
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('departure_time')
        .map(
          (rows) => rows
              .map((r) => Trip.fromJson((r as Map).cast<String, dynamic>()))
              .toList(),
        );
  }

  Stream<List<Trip>> watchMyRecurringTrips(String driverId) {
    // DEV MODE: Return mock recurring trips
    if (kUseDevMode) {
      return Stream.value(_mockTrips.where((t) => t.isRecurring).toList());
    }
    return sb
        .from(DbTable.trips)
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('departure_time')
        .map(
          (rows) => rows
              .where(
                (r) => ((r as Map)['is_recurring'] as bool?) ?? false,
              )
              .map((r) => Trip.fromJson((r as Map).cast<String, dynamic>()))
              .toList(),
        );
  }

  // Marketplace search.
  // Note: This is a basic filter/ranking implementation; richer geo search can be
  // implemented later via PostGIS or an RPC.
  Future<List<Trip>> searchTrips(TripSearchQuery q) async {
    // DEV MODE: Return mock trips with filtering
    if (kUseDevMode) {
      var trips = List<Trip>.from(_mockTrips);
      if (q.womenOnly == true) {
        trips = trips.where((t) => t.womenOnly).toList();
      }
      if (q.minSeats != null) {
        trips = trips.where((t) => t.seatsAvailable >= q.minSeats!).toList();
      }
      if (q.earliestDeparture != null) {
        trips = trips
            .where((t) => !t.departureTime.isBefore(q.earliestDeparture!))
            .toList();
      }
      if (q.latestDeparture != null) {
        trips = trips
            .where((t) => !t.departureTime.isAfter(q.latestDeparture!))
            .toList();
      }
      return trips;
    }

    // Basic filtering example - replaced with RPC later if needed
    var query = sb.from(DbTable.trips).select().eq('status', 'planned');

    if (q.womenOnly == true) {
      query = query.eq('women_only', true);
    }
    if (q.minSeats != null) {
      query = query.gte('seats_available', q.minSeats!);
    }
    if (q.earliestDeparture != null) {
      query = query.gte(
        'departure_time',
        q.earliestDeparture!.toUtc().toIso8601String(),
      );
    }
    if (q.latestDeparture != null) {
      query = query.lte(
        'departure_time',
        q.latestDeparture!.toUtc().toIso8601String(),
      );
    }

    // Optional: add geo-filtering logic (PostGIS or haversine/RPC) later.

    final res = await RetryUtils.retry(
      () => query,
      retryIf: RetryUtils.shouldRetrySupabaseError,
    );
    var trips = (res as List)
        .map((e) => Trip.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    // AI Module A: Fetch Match Scores if User is authenticated
    final myId = sb.auth.currentUser?.id;
    if (myId != null && trips.isNotEmpty) {
      try {
        // Fetch scores for these trips
        final tripIds = trips.map((t) => t.id).toList();

        // Server-side scoring (Edge Function)
        try {
          await RetryUtils.retry(
            () => sb.functions.invoke(
              EdgeFn.scoreMatches,
              body: {'trip_ids': tripIds},
            ),
            retryIf: RetryUtils.shouldRetrySupabaseError,
          );
        } catch (_) {
          // safe fallback: search still works without AI
        }

        final scoresData = await RetryUtils.retry(
          () => sb
              .from(DbTable.matchScores)
              .select()
              .eq('user_id', myId)
              .filter('trip_id', 'in', tripIds),
          retryIf: RetryUtils.shouldRetrySupabaseError,
        );

        final scoresMap = {
          for (var s in (scoresData as List)) s['trip_id'] as String: s,
        };

        // Map scores to trips
        trips = trips.map((t) {
          final s = scoresMap[t.id];
          if (s != null) {
            return Trip.fromJson({
              ...t.toJson(),
              'match_score': s['match_score'],
              'accept_prob': s['accept_prob'],
              'explanation_tags': s['explanation_tags'],
            });
          }
          return t;
        }).toList();

        // Sort by Match Score Descending
        trips.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
      } catch (e) {
        // Fail silently on score fetch error to keep search working
        debugPrint('Error fetching match scores: $e');
      }
    }

    trips = await _attachTrustInfo(trips);
    return trips;
  }

  // Helper to attach trust info
  Future<List<Trip>> _attachTrustInfo(List<Trip> trips) async {
    if (trips.isEmpty) return trips;
    final driverIds = trips.map((t) => t.driverId).toSet().toList();

    try {
      final data = await sb
          .from(DbTable.trustProfiles)
          .select('user_id, trust_score, trust_badge')
          .inFilter('user_id', driverIds);

      final trustMap = {
        for (var row in (data as List)) row['user_id'] as String: row,
      };

      return trips.map((t) {
        final trust = trustMap[t.driverId];
        if (trust != null) {
          return Trip.fromJson({
            ...t.toJson(),
            'driver_trust_score': trust['trust_score'],
            'driver_trust_badge': trust['trust_badge'],
          });
        }
        return t;
      }).toList();
    } catch (e) {
      debugPrint('Error attaching trust info: $e');
      return trips;
    }
  }

  // Create trip (OfferRideController uses this)
  Future<Trip> createTrip(Trip draft) async {
    final res = await RetryUtils.retry(
      () => sb.from(DbTable.trips).insert(draft.toDbJson()).select().single(),
      retryIf: RetryUtils.shouldRetrySupabaseError,
    );
    return Trip.fromJson(res);
  }

  Future<Trip> updateTrip(String tripId, Map<String, dynamic> patch) async {
    final res = await sb
        .from(DbTable.trips)
        .update(patch)
        .eq('id', tripId)
        .select()
        .single();
    return Trip.fromJson(res);
  }

  Future<void> deleteTrip(String tripId) async {
    await sb.from(DbTable.trips).delete().eq('id', tripId);
  }

  // AI Module C: Dynamic XP Incentives & AI Departure Optimizer
  Future<ComputeIncentivesResponse> fetchDriverIncentives({
    required double lat,
    required double lng,
    DateTime? time,
  }) async {
    // DEV MODE: Mock AI suggestion logic
    if (kUseDevMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final checkTime = time ?? DateTime.now();
      final hour = checkTime.hour;

      SmartDepartureSuggestion? suggestion;

      // Simple mock logic: Peak hours are 7-9 AM and 4-7 PM
      final isMorningPeak = hour >= 7 && hour < 9;
      final isEveningPeak = hour >= 16 && hour < 19;

      if (isMorningPeak || isEveningPeak) {
        // Suggest 45 mins later to avoid "Zahma"
        final suggested = checkTime.add(const Duration(minutes: 45));
        suggestion = SmartDepartureSuggestion(
          suggestedTime: suggested,
          scoreImprovement: 0.85,
          reasonEn:
              "Traffic is heavy right now. Leaving at ${suggested.hour}:${suggested.minute.toString().padLeft(2, '0')} avoids peak Zahma and scores 2x XP!",
          reasonAr:
              "الزحمة شديدة حالياً. الانطلاق الساعة ${suggested.hour}:${suggested.minute.toString().padLeft(2, '0')} يجنبك الذروة ويمنحك ضعف نقاط الخبرة!",
        );
      }

      return ComputeIncentivesResponse(
        multiplier: suggestion != null ? 2.0 : 1.0,
        areaId: "Riyadh Digital City",
        suggestion: suggestion,
        validUntil: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    try {
      final req = ComputeIncentivesRequest(
        lat: lat,
        lng: lng,
        time: time ?? DateTime.now(),
      );
      final res = await RetryUtils.retry(
        () => sb.functions.invoke(
          EdgeFn.computeIncentives,
          body: req.toJson(),
        ),
        retryIf: RetryUtils.shouldRetrySupabaseError,
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw ComputeIncentivesFailure('Malformed response');
      }
      return ComputeIncentivesResponse.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching incentives: $e');
      throw ComputeIncentivesFailure(e.toString());
    }
  }

  // XP Crediting: Explicitly complete trip and award XP
  Future<void> completeTripV2(String tripId) async {
    // DEV MODE: Mock completion
    if (kUseDevMode) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return;
    }

    try {
      // 1. Fetch the trip details to check for 'faza' tags.
      final tripData = await RetryUtils.retry(
        () => sb.from(DbTable.trips).select().eq('id', tripId).single(),
        retryIf: RetryUtils.shouldRetrySupabaseError,
      );
      final tags = List<String>.from(tripData['tags'] as List? ?? []);

      // 2. Call the RPC to complete the trip and process standard XP
      await sb.rpc<void>('complete_trip_v2', params: {'p_trip_id': tripId});

      // 3. Process localized bonus Faz'a gamification
      if (tags.contains('faza')) {
        try {
          // Log localized extra Faz'a completion XP event. Assumes gamification service handles the point increment.
          await sb.from(DbTable.eventLog).insert({
            'actor_id': sb.auth.currentUser?.id,
            'event_type': 'mission_completed',
            'entity_type': 'mission',
            'entity_id': 'faza_hero',
            'payload': {'reward_xp': 500, 'trip_id': tripId},
          });
        } catch (e) {
          debugPrint('Failed to log Faza bonus: $e');
        }
      }
    } on PostgrestException catch (e) {
      debugPrint('Error completing trip (Postgrest): ${e.message}');
      throw Exception('Failed to complete trip: ${e.message}');
    } catch (e) {
      debugPrint('Error completing trip: $e');
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<void> submitRating({
    required String tripId,
    required String rateeId,
    required int stars,
    List<String>? tags,
    String? comment,
  }) async {
    try {
      await RetryUtils.retry(
        () => sb.rpc<void>(
          'submit_rating',
          params: {
            'p_trip_id': tripId,
            'p_ratee_id': rateeId,
            'p_stars': stars,
            'p_tags': tags ?? [],
            'p_comment': comment ?? '',
          },
        ),
        retryIf: RetryUtils.shouldRetrySupabaseError,
      );

      // After rating, trigger behavior scoring recalculation
      await RetryUtils.retry(
        () => sb.functions.invoke(
          EdgeFn.driverBehaviorScoring,
          body: {'driver_id': rateeId},
        ),
        retryIf: RetryUtils.shouldRetrySupabaseError,
      );
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      throw Exception('Failed to submit rating: $e');
    }
  }

  Future<int?> estimateEta({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final res = await sb.functions.invoke(
        EdgeFn.etaEstimation,
        body: {
          'origin': {'lat': originLat, 'lng': originLng},
          'destination': {'lat': destLat, 'lng': destLng},
        },
      );
      return (res.data['eta_minutes'] as num?)?.toInt();
    } catch (e) {
      debugPrint('Error estimating ETA: $e');
      return null;
    }
  }

  Future<void> updateTripEta(String tripId, int etaMinutes) async {
    if (kUseDevMode) {
      debugPrint('DEV MODE: Updating trip $tripId ETA to $etaMinutes mins');
      return;
    }
    await sb.from(DbTable.trips).update({
      'eta_minutes': etaMinutes,
    }).eq('id', tripId);
  }

  Future<void> updateTripPolyline(String tripId, String polyline) async {
    if (kUseDevMode) {
      debugPrint('DEV MODE: Updating trip $tripId polyline');
      return;
    }
    await sb.from(DbTable.trips).update({
      'polyline': polyline,
    }).eq('id', tripId);
  }

  // --- Live Tracking & Lifecycle Extensions ---

  Future<void> startTrip(String tripId) async {
    await sb.from(DbTable.trips).update({'status': 'active'}).eq('id', tripId);
  }

  Future<void> pushLocation({
    required String tripId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) async {
    final myId = sb.auth.currentUser?.id;
    if (myId == null) return;

    await sb.from(DbTable.tripLocations).insert({
      'trip_id': tripId,
      'user_id': myId,
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
    });
  }

  Stream<Map<String, double>> watchTripLocation(String tripId) {
    return sb
        .from(DbTable.tripLocations)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return {};
          final row = rows.first;
          return {
            'lat': (row['lat'] as num).toDouble(),
            'lng': (row['lng'] as num).toDouble(),
          };
        });
  }
}
