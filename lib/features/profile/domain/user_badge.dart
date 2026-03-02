/// User badge model.
class UserBadge {
  final String id;
  final String key;
  final BadgeType type;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final bool isVisible;
  final String? iconUrl;
  final DateTime earnedAt;
  final DateTime? revokedAt;

  const UserBadge({
    required this.id,
    required this.key,
    required this.type,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.isVisible,
    this.iconUrl,
    required this.earnedAt,
    this.revokedAt,
  });

  /// Whether the badge is currently active (not revoked)
  bool get isActive => revokedAt == null;

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    // Handle joined query from user_badges + badges
    final badge = json['badges'] as Map<String, dynamic>? ?? json;
    return UserBadge(
      id: json['id'] as String? ?? badge['id'] as String,
      key: badge['key'] as String,
      type: BadgeTypeX.fromString(badge['type'] as String?),
      nameEn: badge['name_en'] as String,
      nameAr: badge['name_ar'] as String,
      descriptionEn: badge['description_en'] as String?,
      descriptionAr: badge['description_ar'] as String?,
      isVisible: badge['is_visible'] as bool? ?? true,
      iconUrl: badge['icon_url'] as String?,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'] as String)
          : DateTime.now(),
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
    );
  }

  /// Returns localized name based on RTL
  String name(bool isRtl) => isRtl ? nameAr : nameEn;

  /// Returns localized description based on RTL
  String? description(bool isRtl) => isRtl ? descriptionAr : descriptionEn;
}

/// Badge types
enum BadgeType {
  /// AI + ratings driven (Safe Driver, Calm Driver, etc.)
  behavior,

  /// Milestone-based (10 Trips, Peak-Hour Hero, etc.)
  contribution,

  /// Family & trust related (Kids-Approved, Parent-Verified, etc.)
  family,
}

extension BadgeTypeX on BadgeType {
  static BadgeType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'contribution':
        return BadgeType.contribution;
      case 'family':
        return BadgeType.family;
      default:
        return BadgeType.behavior;
    }
  }

  String get displayName {
    switch (this) {
      case BadgeType.behavior:
        return 'Behavior';
      case BadgeType.contribution:
        return 'Contribution';
      case BadgeType.family:
        return 'Family & Trust';
    }
  }

  String get displayNameAr {
    switch (this) {
      case BadgeType.behavior:
        return 'السلوك';
      case BadgeType.contribution:
        return 'المساهمة';
      case BadgeType.family:
        return 'العائلة والثقة';
    }
  }
}
