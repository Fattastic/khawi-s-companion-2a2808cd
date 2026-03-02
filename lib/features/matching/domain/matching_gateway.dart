import 'package:khawi_flutter/features/trips/domain/trip.dart';

/// Result of AI matching algorithm.
///
/// Contains the trip, a normalized match score (0-100),
/// explanation tags for UI display, and predicted acceptance probability.
class Match {
  const Match({
    required this.trip,
    required this.score,
    this.explanationTags = const [],
    this.acceptProbability = 0.0,
    this.etaMinutes,
  });

  /// The matched trip.
  final Trip trip;

  /// Match score from 0 (poor match) to 100 (perfect match).
  final int score;

  /// Human-readable tags explaining the match (e.g., "Same neighborhood", "Compatible schedule").
  final List<String> explanationTags;

  /// AI-predicted probability that user will accept this match (0.0 - 1.0).
  final double acceptProbability;

  /// Estimated time of arrival in minutes.
  final int? etaMinutes;

  /// Create a copy with updated fields.
  Match copyWith({
    Trip? trip,
    int? score,
    List<String>? explanationTags,
    double? acceptProbability,
    int? etaMinutes,
  }) {
    return Match(
      trip: trip ?? this.trip,
      score: score ?? this.score,
      explanationTags: explanationTags ?? this.explanationTags,
      acceptProbability: acceptProbability ?? this.acceptProbability,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }
}

/// Request parameters for smart matching.
class MatchRequest {
  const MatchRequest({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.departureTime,
    this.womenOnly,
    this.maxResults = 20,
  });

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final DateTime? departureTime;
  final bool? womenOnly;
  final int maxResults;
}

/// Result of bundling multiple passenger stops into an optimized route.
class BundleResult {
  const BundleResult({
    required this.rankScore,
    required this.stops,
  });

  /// Overall route efficiency score (higher is better).
  final int rankScore;

  /// Ordered list of stops with type (pickup/dropoff) and location info.
  final List<BundleStop> stops;
}

/// A single stop in a bundled route.
class BundleStop {
  const BundleStop({
    required this.type,
    required this.label,
    this.lat,
    this.lng,
    this.passengerId,
  });

  /// Either 'pickup' or 'dropoff'.
  final String type;

  /// Human-readable label for this stop.
  final String label;

  /// Latitude of the stop.
  final double? lat;

  /// Longitude of the stop.
  final double? lng;

  /// ID of the passenger for this stop.
  final String? passengerId;

  factory BundleStop.fromJson(Map<String, dynamic> json) {
    return BundleStop(
      type: json['type'] as String? ?? 'pickup',
      label: json['label'] as String? ?? 'Stop',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      passengerId: json['passenger_id'] as String?,
    );
  }
}

/// Exception thrown when matching fails.
class MatchingException implements Exception {
  const MatchingException(this.message);
  final String message;

  @override
  String toString() => 'MatchingException: $message';
}

/// Abstract gateway for AI-powered matching operations.
///
/// This abstraction allows swapping between:
/// - Edge Function implementation (production)
/// - Node.js server implementation (alternative)
/// - Mock implementation (testing/development)
///
/// UI code should never know which implementation is in use.
abstract class MatchingGateway {
  /// Find trips that match the passenger's route and preferences.
  ///
  /// Returns a list of [Match] objects sorted by score (highest first).
  /// Throws [MatchingException] on failure.
  Future<List<Match>> smartMatch(MatchRequest request);

  /// Bundle multiple passenger stops into an optimized route order.
  ///
  /// Used by drivers to get AI-suggested pickup/dropoff sequence.
  /// Returns null if bundling fails or is not applicable.
  Future<BundleResult?> bundleStops({
    required String tripId,
    required List<String> passengerIds,
  });

  /// Score a specific set of trips for a passenger.
  ///
  /// Unlike [smartMatch], this scores pre-fetched trips rather than
  /// searching the database. Used when trips are already loaded.
  Future<Map<String, Match>> scoreTrips({
    required List<Trip> trips,
    required MatchRequest request,
  });
}
