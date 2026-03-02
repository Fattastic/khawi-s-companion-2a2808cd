import 'package:khawi_flutter/features/fare_estimate/domain/fare_estimate.dart';

import 'ride_history_entry.dart';

class RideReceiptSummary {
  const RideReceiptSummary({
    required this.receiptNumber,
    required this.durationMinutes,
    required this.estimatedFareSar,
    required this.estimatedPerPassengerSar,
  });

  final String receiptNumber;
  final int durationMinutes;
  final double estimatedFareSar;
  final double estimatedPerPassengerSar;
}

RideReceiptSummary buildRideReceiptSummary(
  RideHistoryEntry entry, {
  int fallbackDurationMinutes = 30,
  int defaultSeatCount = 2,
}) {
  final duration = _deriveDurationMinutes(
    entry,
    fallbackDurationMinutes: fallbackDurationMinutes,
  );

  final estimate = calculateFareEstimate(
    distanceKm: entry.distanceKm ?? 0,
    durationMinutes: duration,
    seatCount: defaultSeatCount,
  );

  final date = entry.departureTime;
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final shortTrip =
      entry.tripId.length <= 6 ? entry.tripId : entry.tripId.substring(0, 6);

  return RideReceiptSummary(
    receiptNumber: 'KHW-$y$m$d-$shortTrip',
    durationMinutes: duration,
    estimatedFareSar: estimate.totalFareSar,
    estimatedPerPassengerSar: estimate.perPassengerFareSar,
  );
}

int _deriveDurationMinutes(
  RideHistoryEntry entry, {
  required int fallbackDurationMinutes,
}) {
  final completedAt = entry.completedAt;
  if (completedAt == null) return fallbackDurationMinutes;

  final diff = completedAt.difference(entry.departureTime).inMinutes;
  if (diff <= 0) return fallbackDurationMinutes;
  return diff;
}
