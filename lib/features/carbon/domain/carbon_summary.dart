class CarbonTripImpact {
  const CarbonTripImpact({
    required this.tripId,
    required this.departureTime,
    required this.originLabel,
    required this.destLabel,
    required this.co2SavedKg,
    required this.distanceKm,
  });

  final String tripId;
  final DateTime departureTime;
  final String? originLabel;
  final String? destLabel;
  final double co2SavedKg;
  final double? distanceKm;
}

class CarbonSummary {
  const CarbonSummary({
    required this.totalCo2SavedKg,
    required this.totalDistanceKm,
    required this.tripsCount,
    required this.averageCo2PerTripKg,
    required this.equivalentTreeMonths,
    required this.recentImpacts,
  });

  final double totalCo2SavedKg;
  final double totalDistanceKm;
  final int tripsCount;
  final double averageCo2PerTripKg;
  final double equivalentTreeMonths;
  final List<CarbonTripImpact> recentImpacts;

  static const empty = CarbonSummary(
    totalCo2SavedKg: 0,
    totalDistanceKm: 0,
    tripsCount: 0,
    averageCo2PerTripKg: 0,
    equivalentTreeMonths: 0,
    recentImpacts: <CarbonTripImpact>[],
  );
}

CarbonSummary summarizeCarbonTrips(List<CarbonTripImpact> trips) {
  if (trips.isEmpty) return CarbonSummary.empty;

  final totalCo2 =
      trips.fold<double>(0, (sum, entry) => sum + entry.co2SavedKg);
  final totalDistance =
      trips.fold<double>(0, (sum, entry) => sum + (entry.distanceKm ?? 0));
  final avgCo2 = totalCo2 / trips.length;

  // Approximation: one tree absorbs ~21.77 kg CO2/year.
  final treeMonths = (totalCo2 / 21.77) * 12;

  return CarbonSummary(
    totalCo2SavedKg: totalCo2,
    totalDistanceKm: totalDistance,
    tripsCount: trips.length,
    averageCo2PerTripKg: avgCo2,
    equivalentTreeMonths: treeMonths,
    recentImpacts: trips,
  );
}
