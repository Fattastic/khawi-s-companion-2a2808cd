import 'dart:convert';

class ComputeIncentivesRequest {
  final double lat;
  final double lng;
  final DateTime time;

  const ComputeIncentivesRequest({
    required this.lat,
    required this.lng,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'time': time.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}

class SmartDepartureSuggestion {
  final DateTime suggestedTime;
  final double scoreImprovement;
  final String reasonEn;
  final String reasonAr;

  const SmartDepartureSuggestion({
    required this.suggestedTime,
    required this.scoreImprovement,
    required this.reasonEn,
    required this.reasonAr,
  });

  factory SmartDepartureSuggestion.fromJson(Map<String, dynamic> json) {
    return SmartDepartureSuggestion(
      suggestedTime: DateTime.parse(json['suggested_time'] as String),
      scoreImprovement: (json['score_improvement'] as num).toDouble(),
      reasonEn: json['reason_en'] as String,
      reasonAr: json['reason_ar'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'suggested_time': suggestedTime.toIso8601String(),
        'score_improvement': scoreImprovement,
        'reason_en': reasonEn,
        'reason_ar': reasonAr,
      };
}

class ComputeIncentivesResponse {
  final double multiplier;
  final String areaId;
  final DateTime? validUntil;
  final SmartDepartureSuggestion? suggestion;

  const ComputeIncentivesResponse({
    required this.multiplier,
    required this.areaId,
    this.validUntil,
    this.suggestion,
  });

  factory ComputeIncentivesResponse.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('multiplier') || !json.containsKey('area_id')) {
      throw const FormatException('Missing multiplier or area_id');
    }
    return ComputeIncentivesResponse(
      multiplier: (json['multiplier'] as num).toDouble(),
      areaId: json['area_id'] as String,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'] as String)
          : null,
      suggestion: json['suggestion'] != null
          ? SmartDepartureSuggestion.fromJson(
              json['suggestion'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ComputeIncentivesFailure implements Exception {
  final String message;
  ComputeIncentivesFailure(this.message);
  @override
  String toString() => 'ComputeIncentivesFailure: $message';
}
