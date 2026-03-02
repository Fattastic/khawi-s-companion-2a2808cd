import 'gamification_enums.dart';

/// A recommended next-best-action for the user.
class NextBestAction {
  const NextBestAction({
    required this.actionType,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.potentialXp,
    required this.deepLink,
    required this.expiresAt,
    this.reason,
    this.confidenceScore,
  });

  final ActionType actionType;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final int potentialXp;
  final String? deepLink;
  final DateTime? expiresAt;

  /// Machine-readable explainability key (e.g. 'streak_in_grace').
  final String? reason;

  /// 0.0–1.0 confidence score from the recommendation engine.
  final double? confidenceScore;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  String localizedTitle({required bool isRtl}) => isRtl ? titleAr : title;

  String localizedSubtitle({required bool isRtl}) =>
      isRtl ? subtitleAr : subtitle;

  factory NextBestAction.fromJson(Map<String, dynamic> json) => NextBestAction(
        actionType: ActionType.fromString(
          json['action_type'] as String? ?? 'take_ride',
        ),
        title: json['title_en'] as String? ?? json['title'] as String? ?? '',
        titleAr: json['title_ar'] as String? ?? '',
        subtitle:
            json['subtitle_en'] as String? ?? json['subtitle'] as String? ?? '',
        subtitleAr: json['subtitle_ar'] as String? ?? '',
        potentialXp: json['potential_xp'] as int? ?? 0,
        deepLink: json['deep_link'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        reason: json['reason'] as String?,
        confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      );
}
