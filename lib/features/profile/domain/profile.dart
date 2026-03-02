import 'package:khawi_flutter/models/user_role.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';
export 'package:khawi_flutter/models/user_role.dart';

UserRole roleFromString(String v) => switch (v) {
      'driver' => UserRole.driver,
      'junior' => UserRole.junior,
      _ => UserRole.passenger,
    };
String roleToString(UserRole r) => switch (r) {
      UserRole.passenger => 'passenger',
      UserRole.driver => 'driver',
      UserRole.junior => 'junior',
    };

class Profile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final UserRole? role;
  final bool isPremium;
  final bool isVerified;
  final int totalXp;
  final int redeemableXp;

  bool get isComplete => fullName.isNotEmpty && role != null;

  TrustTier get tier => TrustTierX.fromProfile(
        isIdentityVerified: isIdentityVerified,
        trustBadge: trustBadge,
      );

  /// Whether the user has completed minimal profile setup (fullName required).
  bool get isMinimalProfileComplete => fullName.isNotEmpty;

  final String? gender;
  final String? neighborhoodId;
  final double? trustScore;
  final String? trustBadge;
  final bool xpThrottle;
  final DateTime? xpThrottleUntil;

  // ── Driver Trust & Verification Fields ──
  /// Whether identity has been verified (e.g. via Nafath).
  final bool isIdentityVerified;

  /// Timestamp of identity verification.
  final DateTime? identityVerifiedAt;

  /// Provider used for identity verification (e.g. "nafath").
  final String? identityProvider;

  /// Vehicle ownership verification status: pending | approved | rejected | none.
  final String vehicleVerificationStatus;

  /// Timestamp of vehicle verification decision.
  final DateTime? vehicleVerifiedAt;

  /// Plate number (stored after verification submission).
  final String? vehiclePlateNumber;

  /// Vehicle model description (e.g. "Toyota Camry 2023").
  final String? vehicleModel;

  /// Average star rating from ride reviews (1.0-5.0).
  final double? averageRating;

  /// Total number of ratings received.
  final int totalRatings;

  /// Whether all driver trust requirements are met.
  bool get isDriverTrustComplete =>
      isIdentityVerified && vehicleVerificationStatus == 'approved';

  const Profile({
    required this.id,
    required this.fullName,
    this.role,
    required this.isPremium,
    required this.isVerified,
    required this.totalXp,
    required this.redeemableXp,
    this.avatarUrl,
    this.gender,
    this.neighborhoodId,
    this.trustScore,
    this.trustBadge,
    this.xpThrottle = false,
    this.xpThrottleUntil,
    this.isIdentityVerified = false,
    this.identityVerifiedAt,
    this.identityProvider,
    this.vehicleVerificationStatus = 'none',
    this.vehicleVerifiedAt,
    this.vehiclePlateNumber,
    this.vehicleModel,
    this.averageRating,
    this.totalRatings = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        fullName: (j['full_name'] as String?) ?? '',
        avatarUrl: j['avatar_url'] as String?,
        role: j['role'] == null ? null : roleFromString(j['role'] as String),
        isPremium: (j['is_premium'] as bool?) ?? false,
        isVerified: (j['is_verified'] as bool?) ?? false,
        totalXp: (j['total_xp'] as int?) ?? 0,
        redeemableXp: (j['redeemable_xp'] as int?) ?? 0,
        gender: j['gender'] as String?,
        neighborhoodId: j['neighborhood_id'] as String?,
        trustScore: (j['trust_score'] as num?)?.toDouble(),
        trustBadge: j['trust_badge'] as String?,
        xpThrottle: (j['xp_throttle'] as bool?) ?? false,
        xpThrottleUntil: j['xp_throttle_until'] != null
            ? DateTime.parse(j['xp_throttle_until'] as String)
            : null,
        isIdentityVerified: (j['is_identity_verified'] as bool?) ?? false,
        identityVerifiedAt: j['identity_verified_at'] != null
            ? DateTime.parse(j['identity_verified_at'] as String)
            : null,
        identityProvider: j['identity_provider'] as String?,
        vehicleVerificationStatus:
            (j['vehicle_verification_status'] as String?) ?? 'none',
        vehicleVerifiedAt: j['vehicle_verified_at'] != null
            ? DateTime.parse(j['vehicle_verified_at'] as String)
            : null,
        vehiclePlateNumber: j['vehicle_plate_number'] as String?,
        vehicleModel: j['vehicle_model'] as String?,
        averageRating: (j['average_rating'] as num?)?.toDouble(),
        totalRatings: (j['total_ratings'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role != null ? roleToString(role!) : null,
        'is_premium': isPremium,
        'is_verified': isVerified,
        'total_xp': totalXp,
        'redeemable_xp': redeemableXp,
        'gender': gender,
        'neighborhood_id': neighborhoodId,
        'trust_score': trustScore,
        'trust_badge': trustBadge,
        'xp_throttle': xpThrottle,
        'xp_throttle_until': xpThrottleUntil?.toIso8601String(),
        'is_identity_verified': isIdentityVerified,
        'identity_verified_at': identityVerifiedAt?.toIso8601String(),
        'identity_provider': identityProvider,
        'vehicle_verification_status': vehicleVerificationStatus,
        'vehicle_verified_at': vehicleVerifiedAt?.toIso8601String(),
        'vehicle_plate_number': vehiclePlateNumber,
        'vehicle_model': vehicleModel,
        'average_rating': averageRating,
        'total_ratings': totalRatings,
      };
}
