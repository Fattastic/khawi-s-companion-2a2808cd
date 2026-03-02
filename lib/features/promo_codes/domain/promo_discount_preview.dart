class PromoDiscountPreview {
  const PromoDiscountPreview({
    required this.applied,
    required this.message,
    required this.discountSar,
    required this.finalFareSar,
  });

  final bool applied;
  final String message;
  final double discountSar;
  final double finalFareSar;

  factory PromoDiscountPreview.fromJson(Map<String, dynamic> json) {
    return PromoDiscountPreview(
      applied: json['applied'] as bool? ?? false,
      message: (json['message'] ?? '').toString(),
      discountSar: (json['discount_sar'] as num?)?.toDouble() ?? 0,
      finalFareSar: (json['final_fare_sar'] as num?)?.toDouble() ?? 0,
    );
  }
}

double computePromoDiscount({
  required String discountType,
  required double discountValue,
  required double fareSar,
  double? maxDiscountSar,
}) {
  if (fareSar <= 0 || discountValue <= 0) return 0;

  var discount = discountType == 'percent'
      ? fareSar * (discountValue / 100)
      : discountValue;

  if (maxDiscountSar != null && maxDiscountSar > 0) {
    discount = discount > maxDiscountSar ? maxDiscountSar : discount;
  }

  return discount > fareSar ? fareSar : discount;
}
