import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/features/matching/domain/premium_matching_boost.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/features/trips/data/trips_repo.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/error/error_mapper.dart';

class RideMarketplaceState {
  final TripSearchQuery? query;
  final List<Trip> trips;
  final bool isLoading;
  final String? error;
  final Trip? selectedTrip;

  RideMarketplaceState({
    this.query,
    this.trips = const [],
    this.isLoading = false,
    this.error,
    this.selectedTrip,
  });

  RideMarketplaceState copyWith({
    TripSearchQuery? query,
    List<Trip>? trips,
    bool? isLoading,
    String? error,
    Trip? selectedTrip,
  }) {
    return RideMarketplaceState(
      query: query ?? this.query,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTrip: selectedTrip ?? this.selectedTrip,
    );
  }
}

class RideMarketplaceController
    extends AutoDisposeNotifier<RideMarketplaceState> {
  @override
  RideMarketplaceState build() {
    return RideMarketplaceState();
  }

  Future<void> search(
    TripSearchQuery query, {
    List<String> passengerPreferences = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null, query: query);
    try {
      final results = await ref.read(tripsRepoProvider).searchTrips(query);

      // Module A: SmartMatch Scoring
      // Only run if we have passenger coordinates
      List<Trip> enrichedTrips = results;

      final scores = await ref.read(matchServiceProvider).scoreTrips(
            trips: results,
            originLat: query.originLat,
            originLng: query.originLng,
            destLat: query.destLat,
            destLng: query.destLng,
            passengerPreferences: passengerPreferences,
          );

      enrichedTrips = results.map((t) {
        final s = scores[t.id];
        if (s != null) {
          return t.copyWith(
            matchScore: s.matchScore,
            matchTags: s.explanationTags,
            acceptProb: s.acceptProb,
          );
        }
        return t;
      }).toList();

      final isPremium = ref.read(premiumProvider);
      enrichedTrips = applyPremiumPriorityBoost(
        enrichedTrips,
        isPremium: isPremium,
      );

      // Sort by match score descending, then departure time
      enrichedTrips.sort((a, b) {
        final scoreA = a.matchScore ?? 0;
        final scoreB = b.matchScore ?? 0;
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        return a.departureTime.compareTo(b.departureTime);
      });

      state = state.copyWith(isLoading: false, trips: enrichedTrips);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorMapper.map(e));
    }
  }

  // Example convenience method for generic search
  Future<void> quickSearch({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    bool womenOnly = false,
    DateTime? desiredDeparture,
    List<String> passengerPreferences = const [],
  }) async {
    final now = DateTime.now();
    final earliest = desiredDeparture?.subtract(const Duration(minutes: 30));
    final latest = desiredDeparture?.add(const Duration(hours: 2)) ??
        now.add(const Duration(hours: 24));

    final q = TripSearchQuery(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      minSeats: 1,
      womenOnly: womenOnly ? true : null,
      earliestDeparture: earliest,
      latestDeparture: latest,
    );
    await search(q, passengerPreferences: passengerPreferences);
  }

  Future<void> selectTrip(Trip? trip) async {
    state = state.copyWith(selectedTrip: trip);
  }
}

final rideMarketplaceControllerProvider = NotifierProvider.autoDispose<
    RideMarketplaceController, RideMarketplaceState>(
  RideMarketplaceController.new,
);
