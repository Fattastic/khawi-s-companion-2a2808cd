import 'ride_history_entry.dart';
import 'ride_receipt_summary.dart';

String buildRideReceiptExportText({
  required RideHistoryEntry entry,
  required RideReceiptSummary summary,
  required bool isArabic,
}) {
  final labels = _labels(isArabic);
  final from = entry.originLabel ?? labels.originFallback;
  final to = entry.destLabel ?? labels.destinationFallback;
  final distance = entry.distanceKm == null
      ? labels.na
      : '${entry.distanceKm!.toStringAsFixed(1)} ${isArabic ? 'كم' : 'km'}';
  final completed = entry.completedAt == null
      ? labels.na
      : entry.completedAt!.toIso8601String();

  return [
    '${labels.title}: ${summary.receiptNumber}',
    '${labels.tripId}: ${entry.tripId}',
    '${labels.from}: $from',
    '${labels.to}: $to',
    '${labels.distance}: $distance',
    '${labels.completed}: $completed',
    '${labels.estimatedFare}: ${summary.estimatedFareSar.toStringAsFixed(2)} SAR',
    '${labels.perPassenger}: ${summary.estimatedPerPassengerSar.toStringAsFixed(2)} SAR',
    '${labels.xp}: +${entry.xpEarned ?? 45} XP',
  ].join('\n');
}

_ReceiptLabels _labels(bool isArabic) {
  if (isArabic) {
    return const _ReceiptLabels(
      title: 'الإيصال',
      tripId: 'معرّف الرحلة',
      from: 'من',
      to: 'إلى',
      distance: 'المسافة',
      completed: 'الاكتمال',
      estimatedFare: 'الأجرة التقديرية',
      perPassenger: 'تقسيم الراكب',
      xp: 'نقاط XP',
      na: 'غير متاح',
      originFallback: 'نقطة الانطلاق',
      destinationFallback: 'الوجهة',
    );
  }
  return const _ReceiptLabels(
    title: 'Receipt',
    tripId: 'Trip ID',
    from: 'From',
    to: 'To',
    distance: 'Distance',
    completed: 'Completed',
    estimatedFare: 'Estimated Fare',
    perPassenger: 'Per Passenger',
    xp: 'XP Earned',
    na: 'N/A',
    originFallback: 'Origin',
    destinationFallback: 'Destination',
  );
}

class _ReceiptLabels {
  final String title;
  final String tripId;
  final String from;
  final String to;
  final String distance;
  final String completed;
  final String estimatedFare;
  final String perPassenger;
  final String xp;
  final String na;
  final String originFallback;
  final String destinationFallback;

  const _ReceiptLabels({
    required this.title,
    required this.tripId,
    required this.from,
    required this.to,
    required this.distance,
    required this.completed,
    required this.estimatedFare,
    required this.perPassenger,
    required this.xp,
    required this.na,
    required this.originFallback,
    required this.destinationFallback,
  });
}
