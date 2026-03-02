import 'trip.dart';

List<Trip> buildVisibleMarketplaceTrips({
  required List<Trip> trips,
  required bool businessOnly,
  required bool campusOnly,
  required bool eventOnly,
  required Set<String> selectedPreferences,
  required Set<String> favoriteDriverIds,
}) {
  final hasTagFilters =
      businessOnly || campusOnly || eventOnly || selectedPreferences.isNotEmpty;
  final hasFavoritePrioritization = favoriteDriverIds.isNotEmpty;

  if (!hasTagFilters && !hasFavoritePrioritization) {
    return trips;
  }

  final filtered = hasTagFilters
      ? trips.where(
          (trip) => _matchesFilters(
            trip,
            businessOnly: businessOnly,
            campusOnly: campusOnly,
            eventOnly: eventOnly,
            selectedPreferences: selectedPreferences,
          ),
        )
      : trips;

  final filteredList = filtered.toList(growable: false);
  if (!hasFavoritePrioritization) {
    return filteredList;
  }

  final sorted = List<Trip>.from(filteredList);
  sorted.sort((a, b) {
    final aFav = favoriteDriverIds.contains(a.driverId);
    final bFav = favoriteDriverIds.contains(b.driverId);
    if (aFav != bFav) return aFav ? -1 : 1;

    final bScore = b.matchScore ?? 0;
    final aScore = a.matchScore ?? 0;
    if (aScore != bScore) return bScore.compareTo(aScore);

    return a.departureTime.compareTo(b.departureTime);
  });

  return sorted;
}

bool _matchesFilters(
  Trip trip, {
  required bool businessOnly,
  required bool campusOnly,
  required bool eventOnly,
  required Set<String> selectedPreferences,
}) {
  if (businessOnly && !trip.tags.contains('business_ride')) return false;
  if (campusOnly && !trip.tags.contains('campus_ride')) return false;
  if (eventOnly && !trip.tags.contains('event_ride')) return false;
  if (selectedPreferences.isEmpty) return true;

  final tags = trip.tags.toSet();
  return selectedPreferences.every(tags.contains);
}
