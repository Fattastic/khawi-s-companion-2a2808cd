import 'package:khawi_flutter/features/rating/domain/ride_rating.dart';

class WrittenReviewPreview {
  final String headline;
  final String body;

  const WrittenReviewPreview({
    required this.headline,
    required this.body,
  });
}

WrittenReviewPreview buildWrittenReviewPreview(
  RideRating review, {
  required bool isArabic,
  int maxChars = 140,
}) {
  final stars = '${'★' * review.score}${'☆' * (5 - review.score)}';
  final date = _formatDate(review.createdAt);
  final normalized =
      (review.comment ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

  final body = normalized.isEmpty
      ? (isArabic ? 'لا توجد مراجعة مكتوبة' : 'No written review provided')
      : _truncate(normalized, maxChars);

  return WrittenReviewPreview(
    headline: '$stars • $date',
    body: body,
  );
}

String _truncate(String value, int maxChars) {
  if (maxChars < 2 || value.length <= maxChars) return value;
  return '${value.substring(0, maxChars - 1)}…';
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
