class AreaIncentive {
  final String areaKey;
  final String timeBucket;
  final double multiplier;
  final String reasonTag; // 'demand_high', 'supply_high', 'balanced'
  final DateTime computedAt;
  final Map<String, dynamic> meta;

  const AreaIncentive({
    required this.areaKey,
    required this.timeBucket,
    required this.multiplier,
    required this.reasonTag,
    required this.computedAt,
    required this.meta,
  });

  factory AreaIncentive.fromJson(Map<String, dynamic> json) {
    return AreaIncentive(
      areaKey: json['area_key'] as String,
      timeBucket: json['time_bucket'] as String,
      multiplier: (json['dynamic_xp_multiplier'] as num).toDouble(),
      reasonTag: json['reason_tag'] as String,
      computedAt: DateTime.parse(json['computed_at'] as String),
      meta: json['meta'] as Map<String, dynamic>? ?? {},
    );
  }
}
