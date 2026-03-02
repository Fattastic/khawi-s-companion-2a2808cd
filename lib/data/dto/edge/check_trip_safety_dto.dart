import 'dart:convert';

class CheckTripSafetyRequest {
  final String tripId;
  final double currentLat;
  final double currentLng;
  final int unexpectedStopDuration;
  final double speedKmh;

  CheckTripSafetyRequest({
    required this.tripId,
    required this.currentLat,
    required this.currentLng,
    required this.unexpectedStopDuration,
    required this.speedKmh,
  });

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'current_lat': currentLat,
        'current_lng': currentLng,
        'unexpected_stop_duration': unexpectedStopDuration,
        'speed_kmh': speedKmh,
      };

  String toRawJson() => json.encode(toJson());
}

class CheckTripSafetyResponse {
  final int riskScore;
  final List<String> alerts;
  final List<String> recommendations;

  CheckTripSafetyResponse({
    required this.riskScore,
    required this.alerts,
    required this.recommendations,
  });

  factory CheckTripSafetyResponse.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('risk_score')) {
      throw const FormatException('Missing risk_score');
    }
    return CheckTripSafetyResponse(
      riskScore: (json['risk_score'] as num).toInt(),
      alerts: (json['alerts'] as List?)?.cast<String>() ?? const [],
      recommendations:
          (json['recommendations'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'risk_score': riskScore,
        'alerts': alerts,
        'recommendations': recommendations,
      };
}

class CheckTripSafetyFailure implements Exception {
  final String message;
  CheckTripSafetyFailure(this.message);
  @override
  String toString() => 'CheckTripSafetyFailure: $message';
}
