import 'dart:convert';

class ScoreMatchesRequest {
  final List<String> tripIds;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final List<String> passengerPreferences;

  ScoreMatchesRequest({
    required this.tripIds,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.passengerPreferences = const [],
  });

  Map<String, dynamic> toJson() => {
        'trip_ids': tripIds,
        'passenger_origin': {'lat': originLat, 'lng': originLng},
        'passenger_dest': {'lat': destLat, 'lng': destLng},
        'passenger_preferences': passengerPreferences,
      };

  String toRawJson() => json.encode(toJson());
}

class ScoreMatch {
  final String tripId;
  final int matchScore;
  final List<String> explanationTags;
  final double acceptProb;

  ScoreMatch({
    required this.tripId,
    required this.matchScore,
    required this.explanationTags,
    required this.acceptProb,
  });

  factory ScoreMatch.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('trip_id') || !json.containsKey('match_score')) {
      throw const FormatException('Missing trip_id or match_score');
    }
    return ScoreMatch(
      tripId: json['trip_id'] as String,
      matchScore: (json['match_score'] as num).toInt(),
      explanationTags:
          (json['explanation_tags'] as List?)?.cast<String>() ?? const [],
      acceptProb: (json['accept_prob'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ScoreMatchesResponse {
  final List<ScoreMatch> matches;

  ScoreMatchesResponse({required this.matches});

  factory ScoreMatchesResponse.fromJson(Map<String, dynamic> json) {
    final matchesJson = json['matches'] as List?;
    if (matchesJson == null) {
      throw const FormatException('Missing matches');
    }
    return ScoreMatchesResponse(
      matches: matchesJson
          .map((e) => ScoreMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScoreMatchesFailure implements Exception {
  final String message;
  ScoreMatchesFailure(this.message);
  @override
  String toString() => 'ScoreMatchesFailure: $message';
}
