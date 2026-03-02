/// Community model for Khawi Communities (حارة خاوي).
///
/// Communities group users by neighborhood, workplace, school, or custom interest.
/// Members see shared ride boards and earn trust bonuses within their community.
library;

/// The kind of community.
enum CommunityType {
  neighborhood('neighborhood', 'حارة', 'Neighborhood'),
  workplace('workplace', 'مقر عمل', 'Workplace'),
  school('school', 'مدرسة / جامعة', 'School / University'),
  custom('custom', 'مخصص', 'Custom');

  final String key;
  final String labelAr;
  final String labelEn;

  const CommunityType(this.key, this.labelAr, this.labelEn);

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;

  static CommunityType fromString(String? s) => CommunityType.values.firstWhere(
        (e) => e.key == s,
        orElse: () => CommunityType.custom,
      );
}

/// A single Khawi community.
class Community {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final CommunityType type;
  final String? iconUrl;
  final String? coverUrl;
  final double? lat;
  final double? lng;
  final double radiusKm;
  final String? creatorId;
  final int memberCount;
  final bool isVerified;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const Community({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.type = CommunityType.custom,
    this.iconUrl,
    this.coverUrl,
    this.lat,
    this.lng,
    this.radiusKm = 5,
    this.creatorId,
    this.memberCount = 0,
    this.isVerified = false,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> j) => Community(
        id: j['id'] as String,
        name: j['name'] as String,
        nameAr: j['name_ar'] as String?,
        description: j['description'] as String?,
        type: CommunityType.fromString(j['type'] as String?),
        iconUrl: j['icon_url'] as String?,
        coverUrl: j['cover_url'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        radiusKm: (j['radius_km'] as num?)?.toDouble() ?? 5,
        creatorId: j['creator_id'] as String?,
        memberCount: (j['member_count'] as int?) ?? 0,
        isVerified: (j['is_verified'] as bool?) ?? false,
        isActive: (j['is_active'] as bool?) ?? true,
        metadata: (j['metadata'] as Map<String, dynamic>?) ?? const {},
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'description': description,
        'type': type.key,
        'icon_url': iconUrl,
        'cover_url': coverUrl,
        'radius_km': radiusKm,
        'creator_id': creatorId,
        'member_count': memberCount,
        'is_verified': isVerified,
        'is_active': isActive,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };

  /// JSON shape for insert (server generates id + created_at).
  Map<String, dynamic> toInsertJson() => {
        'name': name,
        if (nameAr != null) 'name_ar': nameAr,
        if (description != null) 'description': description,
        'type': type.key,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (coverUrl != null) 'cover_url': coverUrl,
        'radius_km': radiusKm,
        'creator_id': creatorId,
        'metadata': metadata,
      };

  /// Display name respecting locale.
  String displayName(String locale) {
    if (locale == 'ar' && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return name;
  }

  /// Icon for community type.
  String get typeEmoji => switch (type) {
        CommunityType.neighborhood => '🏘️',
        CommunityType.workplace => '🏢',
        CommunityType.school => '🎓',
        CommunityType.custom => '👥',
      };
}

/// Membership role within a community.
enum CommunityRole {
  admin('admin'),
  moderator('moderator'),
  member('member');

  final String key;
  const CommunityRole(this.key);

  static CommunityRole fromString(String? s) => CommunityRole.values.firstWhere(
        (e) => e.key == s,
        orElse: () => CommunityRole.member,
      );
}

/// A user's membership in a community.
class CommunityMembership {
  final String communityId;
  final String userId;
  final CommunityRole role;
  final DateTime joinedAt;

  /// Joined community data (when fetched with a select join).
  final Community? community;

  const CommunityMembership({
    required this.communityId,
    required this.userId,
    this.role = CommunityRole.member,
    required this.joinedAt,
    this.community,
  });

  factory CommunityMembership.fromJson(Map<String, dynamic> j) {
    final communityData = j['communities'] as Map<String, dynamic>?;
    return CommunityMembership(
      communityId: j['community_id'] as String,
      userId: j['user_id'] as String,
      role: CommunityRole.fromString(j['role'] as String?),
      joinedAt: DateTime.parse(j['joined_at'] as String),
      community:
          communityData != null ? Community.fromJson(communityData) : null,
    );
  }
}

/// A ride shared to a community board.
class CommunityRide {
  final String id;
  final String communityId;
  final String tripId;
  final String postedBy;
  final String? message;
  final DateTime createdAt;

  /// Joined trip data.
  final Map<String, dynamic>? tripData;

  /// Joined poster profile data.
  final Map<String, dynamic>? posterData;

  const CommunityRide({
    required this.id,
    required this.communityId,
    required this.tripId,
    required this.postedBy,
    this.message,
    required this.createdAt,
    this.tripData,
    this.posterData,
  });

  factory CommunityRide.fromJson(Map<String, dynamic> j) => CommunityRide(
        id: j['id'] as String,
        communityId: j['community_id'] as String,
        tripId: j['trip_id'] as String,
        postedBy: j['posted_by'] as String,
        message: j['message'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        tripData: j['trips'] as Map<String, dynamic>?,
        posterData: j['profiles'] as Map<String, dynamic>?,
      );
}
