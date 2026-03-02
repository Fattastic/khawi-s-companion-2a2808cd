import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/features/junior/domain/junior_location.dart';
import 'package:khawi_flutter/state/providers.dart';

class LiveTrackingState {
  final List<JuniorLocation> activeLocations; // History or latest?
  final List<GeoPoint> markerPoints;
  final GeoPoint? lastPosition;
  final bool isLoading;

  LiveTrackingState({
    this.activeLocations = const [],
    this.markerPoints = const [],
    this.lastPosition,
    this.isLoading = true,
  });

  LiveTrackingState copyWith({
    List<JuniorLocation>? activeLocations,
    List<GeoPoint>? markerPoints,
    GeoPoint? lastPosition,
    bool? isLoading,
  }) {
    return LiveTrackingState(
      activeLocations: activeLocations ?? this.activeLocations,
      markerPoints: markerPoints ?? this.markerPoints,
      lastPosition: lastPosition ?? this.lastPosition,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LiveTrackingController
    extends AutoDisposeFamilyNotifier<LiveTrackingState, String> {
  // UI owns the map controller; this controller only exposes map state.

  @override
  LiveTrackingState build(String arg) {
    _initSubscription(arg);
    return LiveTrackingState();
  }

  void _initSubscription(String runId) {
    final sub = ref.watch(juniorRepoProvider).watchRunLocations(runId).listen(
      (locations) {
        if (locations.isEmpty) return;

        final latest = locations.first; // sorted desc
        final lastPos = GeoPoint(latest.lat, latest.lng);

        state = state.copyWith(
          activeLocations: locations,
          markerPoints: [lastPos],
          lastPosition: lastPos,
          isLoading: false,
        );
      },
      onError: (e) {
        // handle error
      },
    );
    ref.onDispose(() => sub.cancel());
  }
}

final liveTrackingControllerProvider = NotifierProvider.autoDispose
    .family<LiveTrackingController, LiveTrackingState, String>(
  LiveTrackingController.new,
);
