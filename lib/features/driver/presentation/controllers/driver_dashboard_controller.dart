import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/trips/domain/area_incentive.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/driver/data/demand_repo.dart';
import 'package:khawi_flutter/data/dto/edge/demand_point_dto.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/error/error_mapper.dart';

class DriverDashboardState {
  final List<AreaIncentive> incentives;
  final List<TripRequest> incomingRequests;
  final List<TripRequest> acceptedRequests;
  final BundleResult? bundleResult;
  final List<DemandPoint> demandPoints;
  final bool isLoading;
  final bool isOnline;
  final Set<String> processingRequestIds;
  final String? errorMessage;

  DriverDashboardState({
    this.incentives = const [],
    this.incomingRequests = const [],
    this.acceptedRequests = const [],
    this.demandPoints = const [],
    this.bundleResult,
    this.isLoading = false,
    this.isOnline = false,
    this.processingRequestIds = const {},
    this.errorMessage,
  });

  DriverDashboardState copyWith({
    List<AreaIncentive>? incentives,
    List<TripRequest>? incomingRequests,
    List<TripRequest>? acceptedRequests,
    List<DemandPoint>? demandPoints,
    BundleResult? bundleResult,
    bool? isLoading,
    bool? isOnline,
    Set<String>? processingRequestIds,
    String? errorMessage,
  }) {
    return DriverDashboardState(
      incentives: incentives ?? this.incentives,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      demandPoints: demandPoints ?? this.demandPoints,
      bundleResult: bundleResult ?? this.bundleResult,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      processingRequestIds: processingRequestIds ?? this.processingRequestIds,
      errorMessage: errorMessage,
    );
  }
}

class DriverDashboardController
    extends AutoDisposeNotifier<DriverDashboardState> {
  @override
  DriverDashboardState build() {
    _initSubscription();
    // Defer data fetch
    Future.microtask(() {
      fetchIncentives();
      fetchDemandForecast();
    });
    return DriverDashboardState();
  }

  void _initSubscription() {
    final realtimeService = ref.watch(realtimeServiceProvider);
    final uid = ref.watch(userIdProvider);

    if (uid == null) return;

    final sub = realtimeService.subscribeToDriverQueue(uid).listen((reqs) {
      final pending =
          reqs.where((r) => r.status == RequestStatus.pending).toList();
      final accepted =
          reqs.where((r) => r.status == RequestStatus.accepted).toList();
      state = state.copyWith(
        incomingRequests: pending,
        acceptedRequests: accepted,
      );
    });

    ref.onDispose(() => sub.cancel());
  }

  Future<void> fetchIncentives() async {
    state = state.copyWith(isLoading: true);

    // Get areas based on driver's current location
    List<String> areas = [];
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      // Generate geohash-based area IDs (simplified: use lat/lng zones)
      final latZone = (position.latitude * 10).floor();
      final lngZone = (position.longitude * 10).floor();
      areas = [
        'zone_${latZone}_$lngZone',
        'zone_${latZone}_${lngZone + 1}',
        'zone_${latZone + 1}_$lngZone',
      ];
    } catch (_) {
      // Fallback to Riyadh zones
      areas = ['zone_247_466', 'zone_247_467', 'zone_248_466'];
    }

    final inc = await ref.read(incentiveRepoProvider).getIncentives(areas);
    state = state.copyWith(isLoading: false, incentives: inc);
  }

  Future<void> fetchDemandForecast() async {
    // Basic location logic derived from geolocation
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final points = await ref
          .read(demandRepoProvider)
          .fetchDemandForecast(position.latitude, position.longitude);
      state = state.copyWith(demandPoints: points);
    } catch (_) {
      // If location fails, we just don't show the heatmap
    }
  }

  void toggleOnline() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void clearError() {
    state = DriverDashboardState(
      incentives: state.incentives,
      incomingRequests: state.incomingRequests,
      acceptedRequests: state.acceptedRequests,
      bundleResult: state.bundleResult,
      isLoading: state.isLoading,
      isOnline: state.isOnline,
      processingRequestIds: state.processingRequestIds,
      errorMessage: null,
    );
  }

  Future<void> acceptRequest(String reqId) async {
    if (state.processingRequestIds.contains(reqId)) return;

    state = state.copyWith(
      processingRequestIds: {...state.processingRequestIds, reqId},
      errorMessage: null,
    );
    KhawiMotion.hapticMedium();

    try {
      await ref.read(requestsRepoProvider).driverAccept(reqId);
    } catch (e) {
      state = state.copyWith(
        processingRequestIds: state.processingRequestIds.difference({reqId}),
        errorMessage: 'Failed to accept: ${ErrorMapper.map(e)}',
      );
      return;
    }

    state = state.copyWith(
      processingRequestIds: state.processingRequestIds.difference({reqId}),
    );
  }

  Future<void> declineRequest(String reqId) async {
    if (state.processingRequestIds.contains(reqId)) return;

    state = state.copyWith(
      processingRequestIds: {...state.processingRequestIds, reqId},
    );

    try {
      await ref.read(requestsRepoProvider).driverDecline(reqId);
    } catch (e) {
      state = state.copyWith(
        processingRequestIds: state.processingRequestIds.difference({reqId}),
        errorMessage: 'Failed to decline: ${ErrorMapper.map(e)}',
      );
      return;
    }

    state = state.copyWith(
      processingRequestIds: state.processingRequestIds.difference({reqId}),
    );
  }

  Future<void> triggerBundle() async {
    if (state.acceptedRequests.isEmpty) return;

    final tripId = state.acceptedRequests.first.tripId;
    final passengerIds =
        state.acceptedRequests.map((r) => r.passengerId).toList();

    state = state.copyWith(isLoading: true);
    final result = await ref.read(matchingGatewayProvider).bundleStops(
          tripId: tripId,
          passengerIds: passengerIds,
        );
    state = state.copyWith(isLoading: false, bundleResult: result);
  }

  void clearBundle() {
    state = DriverDashboardState(
      incentives: state.incentives,
      incomingRequests: state.incomingRequests,
      acceptedRequests: state.acceptedRequests,
      bundleResult: null,
      isLoading: state.isLoading,
      isOnline: state.isOnline,
    );
  }
}

final driverDashboardControllerProvider = NotifierProvider.autoDispose<
    DriverDashboardController, DriverDashboardState>(
  DriverDashboardController.new,
);
