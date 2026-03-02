import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';

/// A redeemable reward from the catalog.
class RewardItem {
  final String id;
  final RewardCategory category;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final int xpCost;
  final TrustTier trustTierRequired;
  final bool subscriptionRequired;
  final int? weeklyCap;
  final String? imageUrl;
  final String? providerLogoUrl;
  final String? termsEn;
  final String? termsAr;
  final bool isActive;

  const RewardItem({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.xpCost,
    required this.trustTierRequired,
    required this.subscriptionRequired,
    this.weeklyCap,
    this.imageUrl,
    this.providerLogoUrl,
    this.termsEn,
    this.termsAr,
    required this.isActive,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] as String,
      category: RewardCategoryX.fromString(json['category'] as String?),
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      xpCost: (json['xp_cost'] as num).toInt(),
      trustTierRequired:
          TrustTierX.fromString(json['trust_tier_required'] as String?),
      subscriptionRequired: json['subscription_required'] as bool? ?? false,
      weeklyCap: (json['weekly_cap'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      providerLogoUrl: json['provider_logo_url'] as String?,
      termsEn: json['terms_en'] as String?,
      termsAr: json['terms_ar'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Returns localized terms based on RTL
  String? terms(bool isRtl) => isRtl ? termsAr : termsEn;

  /// Returns localized name based on RTL
  String name(bool isRtl) => isRtl ? nameAr : nameEn;

  /// Returns localized description based on RTL
  String? description(bool isRtl) => isRtl ? descriptionAr : descriptionEn;
}

/// Reward categories
enum RewardCategory {
  /// Profile highlights, UI flair, labels
  symbolic,

  /// Priority matching, XP boosts, scheduling
  functional,

  /// Fuel, coffee, car wash vouchers (requires Khawi+)
  partner,
}

extension RewardCategoryX on RewardCategory {
  static RewardCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'functional':
        return RewardCategory.functional;
      case 'partner':
        return RewardCategory.partner;
      default:
        return RewardCategory.symbolic;
    }
  }

  String get displayName {
    switch (this) {
      case RewardCategory.symbolic:
        return 'Symbolic';
      case RewardCategory.functional:
        return 'Functional';
      case RewardCategory.partner:
        return 'Partner';
    }
  }

  String get displayNameAr {
    switch (this) {
      case RewardCategory.symbolic:
        return 'رمزية';
      case RewardCategory.functional:
        return 'عملية';
      case RewardCategory.partner:
        return 'شراكات';
    }
  }
}
