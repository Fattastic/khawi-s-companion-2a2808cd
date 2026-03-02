import 'package:khawi_flutter/features/trips/domain/trip.dart';

class SmartRouteSuggestion {
  const SmartRouteSuggestion({
    required this.title,
    required this.departureTime,
    required this.estimatedDurationMinutes,
    required this.confidenceLabel,
    required this.reason,
    this.matchScore,
  });

  final String title;
  final DateTime departureTime;
  final int estimatedDurationMinutes;
  final String confidenceLabel;
  final String reason;
  final int? matchScore;
}

class CommutePattern {
  const CommutePattern({
    required this.routeLabel,
    required this.timeWindowLabel,
    required this.frequency,
    required this.patternScore,
    required this.isPeakWindow,
  });

  final String routeLabel;
  final String timeWindowLabel;
  final int frequency;
  final int patternScore;
  final bool isPeakWindow;
}

List<SmartRouteSuggestion> buildSmartRouteSuggestions(
  List<Trip> trips, {
  DateTime? now,
  int maxResults = 3,
}) {
  final current = now ?? DateTime.now();

  final candidates = trips
      .where(
        (t) =>
            t.status == TripStatus.planned &&
            !t.departureTime.isBefore(
              current.subtract(const Duration(minutes: 15)),
            ),
      )
      .toList(growable: false)
    ..sort(
      (a, b) {
        final recurringCompare =
            (b.isRecurring ? 1 : 0) - (a.isRecurring ? 1 : 0);
        if (recurringCompare != 0) return recurringCompare;

        final scoreA = a.matchScore ?? 0;
        final scoreB = b.matchScore ?? 0;
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);

        return a.departureTime.compareTo(b.departureTime);
      },
    );

  return candidates.take(maxResults).map((trip) {
    final routeTitle =
        '${trip.originLabel ?? 'Route'} → ${trip.destLabel ?? 'Destination'}';

    final score = trip.matchScore;
    final confidence = score == null
        ? 'Good candidate'
        : score >= 85
            ? 'High match probability'
            : score >= 70
                ? 'Balanced demand'
                : 'Exploratory route';

    final reason = trip.isRecurring
        ? 'Recurring commute pattern'
        : (trip.matchTags?.isNotEmpty == true
            ? trip.matchTags!.take(2).join(' • ')
            : 'Suggested from recent route trends');

    final duration = _estimateDurationMinutes(trip);

    return SmartRouteSuggestion(
      title: routeTitle,
      departureTime: trip.departureTime,
      estimatedDurationMinutes: duration,
      confidenceLabel: confidence,
      reason: reason,
      matchScore: score,
    );
  }).toList(growable: false);
}

int _estimateDurationMinutes(Trip trip) {
  final km = trip.distanceKm;
  if (km == null || km <= 0) return 35;

  // Baseline urban commute estimate ~35 km/h.
  final minutes = (km / 35.0) * 60.0;
  final rounded = minutes.round();
  if (rounded < 12) return 12;
  if (rounded > 120) return 120;
  return rounded;
}

List<CommutePattern> detectCommutePatterns(
  List<Trip> trips, {
  int maxResults = 3,
}) {
  final grouped = <String, List<Trip>>{};

  for (final trip in trips) {
    if (trip.status != TripStatus.planned) continue;

    final origin = (trip.originLabel ?? 'Route').trim();
    final destination = (trip.destLabel ?? 'Destination').trim();
    final hourBucket = trip.departureTime.hour;
    final key = '$origin|$destination|$hourBucket';
    grouped.putIfAbsent(key, () => <Trip>[]).add(trip);
  }

  final patterns = grouped.entries.map((entry) {
    final bucketTrips = entry.value;
    final sample = bucketTrips.first;
    final recurringCount = bucketTrips.where((t) => t.isRecurring).length;
    final avgScore = bucketTrips
            .map((t) => t.matchScore ?? 0)
            .fold<int>(0, (sum, score) => sum + score) ~/
        bucketTrips.length;

    final score = (bucketTrips.length * 15) + (recurringCount * 20) + avgScore;
    final hour = sample.departureTime.hour;
    final nextHour = (hour + 1) % 24;
    final isPeak = (hour >= 6 && hour <= 9) || (hour >= 16 && hour <= 20);

    return CommutePattern(
      routeLabel:
          '${sample.originLabel ?? 'Route'} → ${sample.destLabel ?? 'Destination'}',
      timeWindowLabel:
          '${hour.toString().padLeft(2, '0')}:00 - ${nextHour.toString().padLeft(2, '0')}:00',
      frequency: bucketTrips.length,
      patternScore: score,
      isPeakWindow: isPeak,
    );
  }).toList(growable: false)
    ..sort((a, b) {
      if (a.patternScore != b.patternScore) {
        return b.patternScore.compareTo(a.patternScore);
      }
      return b.frequency.compareTo(a.frequency);
    });

  return patterns.take(maxResults).toList(growable: false);
}
