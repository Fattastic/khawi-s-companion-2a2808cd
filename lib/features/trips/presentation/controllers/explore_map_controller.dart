import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/services/permission_service.dart';

class ExploreMapState {
  final GeoPoint? currentLocation;
  final bool isLocationPermissionGranted;
  final bool isLocationPermanentlyDenied;
  final List<GeoPoint> markerPoints;
  final bool isLoading;

  ExploreMapState({
    this.currentLocation,
    this.isLocationPermissionGranted = false,
    this.isLocationPermanentlyDenied = false,
    this.markerPoints = const [],
    this.isLoading = true,
  });

  ExploreMapState copyWith({
    GeoPoint? currentLocation,
    bool? isLocationPermissionGranted,
    bool? isLocationPermanentlyDenied,
    List<GeoPoint>? markerPoints,
    bool? isLoading,
  }) {
    return ExploreMapState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      isLocationPermanentlyDenied:
          isLocationPermanentlyDenied ?? this.isLocationPermanentlyDenied,
      markerPoints: markerPoints ?? this.markerPoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ExploreMapController extends AutoDisposeNotifier<ExploreMapState> {
  @override
  ExploreMapState build() {
    _init();
    return ExploreMapState();
  }

  Future<void> _init() async {
    await checkPermission();
    if (state.isLocationPermissionGranted) {
      await _getCurrentLocation();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Check permission status without requesting (no dialog shown).
  Future<void> checkPermission() async {
    final isGranted = await PermissionService.isLocationPermissionGranted();

    if (isGranted) {
      state = state.copyWith(
        isLocationPermissionGranted: true,
        isLocationPermanentlyDenied: false,
      );
    } else {
      // Check if permanently denied
      final permission = await Geolocator.checkPermission();
      state = state.copyWith(
        isLocationPermissionGranted: false,
        isLocationPermanentlyDenied:
            permission == LocationPermission.deniedForever,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      state = state.copyWith(
        currentLocation: GeoPoint(position.latitude, position.longitude),
        markerPoints: [GeoPoint(position.latitude, position.longitude)],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> recenter() async {
    await _getCurrentLocation();
  }
}

final exploreMapControllerProvider =
    NotifierProvider.autoDispose<ExploreMapController, ExploreMapState>(
  ExploreMapController.new,
);
