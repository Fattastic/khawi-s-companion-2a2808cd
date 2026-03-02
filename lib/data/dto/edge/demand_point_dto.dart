class DemandPoint {
  final double lat;
  final double lng;
  final double intensity; // 0.0 to 1.0
  final String? label;

  const DemandPoint({
    required this.lat,
    required this.lng,
    required this.intensity,
    this.label,
  });

  factory DemandPoint.fromJson(Map<String, dynamic> json) {
    return DemandPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'intensity': intensity,
        'label': label,
      };
}

class DemandForecastResponse {
  final List<DemandPoint> points;
  final DateTime generatedAt;

  const DemandForecastResponse({
    required this.points,
    required this.generatedAt,
  });

  factory DemandForecastResponse.fromJson(Map<String, dynamic> json) {
    return DemandForecastResponse(
      points: (json['points'] as List)
          .map((e) => DemandPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
