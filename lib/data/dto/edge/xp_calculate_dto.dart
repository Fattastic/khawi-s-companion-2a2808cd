class XpCalculateRequest {
  final String userId;
  final int baseXp;
  final String? tripId;
  final DateTime? occurredAt;
  final Map<String, dynamic>? context;

  const XpCalculateRequest({
    required this.userId,
    required this.baseXp,
    this.tripId,
    this.occurredAt,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'base_xp': baseXp,
        if (tripId != null) 'trip_id': tripId,
        if (occurredAt != null) 'occurred_at': occurredAt!.toIso8601String(),
        if (context != null) 'context': context,
      };
}

class XpCalculateResponse {
  final int awardedXp;
  final double multiplier;
  final Map<String, dynamic> breakdown;

  const XpCalculateResponse({
    required this.awardedXp,
    required this.multiplier,
    required this.breakdown,
  });

  factory XpCalculateResponse.fromJson(Map<String, dynamic> json) {
    return XpCalculateResponse(
      awardedXp: (json['awarded_xp'] as num?)?.toInt() ??
          (json['xp'] as num?)?.toInt() ??
          0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      breakdown:
          (json['breakdown'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}
