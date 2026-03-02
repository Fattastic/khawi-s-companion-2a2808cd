class PromoCodeOffer {
  const PromoCodeOffer({
    required this.userPromoId,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountSar,
    required this.minFareSar,
    required this.expiresAt,
    required this.claimedAt,
  });

  final String userPromoId;
  final String code;
  final String title;
  final String discountType;
  final double discountValue;
  final double? maxDiscountSar;
  final double minFareSar;
  final DateTime? expiresAt;
  final DateTime? claimedAt;

  factory PromoCodeOffer.fromJson(Map<String, dynamic> json) {
    return PromoCodeOffer(
      userPromoId: (json['user_promo_id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      discountType: (json['discount_type'] ?? '').toString(),
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
      maxDiscountSar: (json['max_discount_sar'] as num?)?.toDouble(),
      minFareSar: (json['min_fare_sar'] as num?)?.toDouble() ?? 0,
      expiresAt: _parseDate(json['expires_at']),
      claimedAt: _parseDate(json['claimed_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
