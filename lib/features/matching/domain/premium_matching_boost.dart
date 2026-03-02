import 'package:khawi_flutter/features/trips/domain/trip.dart';

const int khawiPremiumPriorityBoost = 8;

List<Trip> applyPremiumPriorityBoost(
  List<Trip> trips, {
  required bool isPremium,
}) {
  if (!isPremium || trips.isEmpty) {
    return trips;
  }

  return trips.map((trip) {
    final base = trip.matchScore ?? 0;
    final boosted = (base + khawiPremiumPriorityBoost).clamp(0, 100);

    final tags = <String>{...(trip.matchTags ?? const <String>[])};
    tags.add('Khawi+ priority');

    return trip.copyWith(
      matchScore: boosted,
      matchTags: tags.toList(growable: false),
    );
  }).toList(growable: false);
}
