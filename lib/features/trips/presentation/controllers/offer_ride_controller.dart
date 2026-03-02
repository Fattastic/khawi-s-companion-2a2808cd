import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/data/dto/edge/compute_incentives_dto.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/error/error_mapper.dart';

class OfferRideState {
  // Step 1: Location
  final double? originLat;
  final double? originLng;
  final String? originLabel;
  final double? destLat;
  final double? destLng;
  final String? destLabel;
  final List<TripWaypoint> waypoints;
  final SmartDepartureSuggestion? suggestion; // New

  // Step 2: Time
  final DateTime? departureTime;

  // Step 3: Preferences
  final int seats;
  final bool womenOnly;
  final Set<String> ridePreferences;
  final bool isRecurring; // Optional
  final bool isBusinessRide;
  final String? companyName;
  final bool isCampusRide;
  final String? campusName;
  final bool isEventRide;
  final String? eventLabel;
  final bool isFazaRide; // New

  // Status
  final bool isLoading;
  final bool isAnalyzingTime; // New
  final String? error;

  OfferRideState({
    this.originLat,
    this.originLng,
    this.originLabel,
    this.destLat,
    this.destLng,
    this.destLabel,
    this.waypoints = const [],
    this.departureTime,
    this.seats = 3,
    this.womenOnly = false,
    this.ridePreferences = const <String>{},
    this.isRecurring = false,
    this.isBusinessRide = false,
    this.companyName,
    this.isCampusRide = false,
    this.campusName,
    this.isEventRide = false,
    this.eventLabel,
    this.isFazaRide = false, // New
    this.isLoading = false,
    this.isAnalyzingTime = false, // New
    this.error,
    this.suggestion, // New
  });

  OfferRideState copyWith({
    double? originLat,
    double? originLng,
    String? originLabel,
    double? destLat,
    double? destLng,
    String? destLabel,
    List<TripWaypoint>? waypoints,
    DateTime? departureTime,
    int? seats,
    bool? womenOnly,
    Set<String>? ridePreferences,
    bool? isRecurring,
    bool? isBusinessRide,
    String? companyName,
    bool? isCampusRide,
    String? campusName,
    bool? isEventRide,
    String? eventLabel,
    bool? isFazaRide, // New
    bool? isLoading,
    bool? isAnalyzingTime, // New
    String? error,
    SmartDepartureSuggestion? suggestion, // New
  }) {
    return OfferRideState(
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      originLabel: originLabel ?? this.originLabel,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      destLabel: destLabel ?? this.destLabel,
      waypoints: waypoints ?? this.waypoints,
      departureTime: departureTime ?? this.departureTime,
      seats: seats ?? this.seats,
      womenOnly: womenOnly ?? this.womenOnly,
      ridePreferences: ridePreferences ?? this.ridePreferences,
      isRecurring: isRecurring ?? this.isRecurring,
      isBusinessRide: isBusinessRide ?? this.isBusinessRide,
      companyName: companyName ?? this.companyName,
      isCampusRide: isCampusRide ?? this.isCampusRide,
      campusName: campusName ?? this.campusName,
      isEventRide: isEventRide ?? this.isEventRide,
      eventLabel: eventLabel ?? this.eventLabel,
      isFazaRide: isFazaRide ?? this.isFazaRide, // New
      isLoading: isLoading ?? this.isLoading,
      isAnalyzingTime: isAnalyzingTime ?? this.isAnalyzingTime, // New
      error: error,
      suggestion: suggestion ?? this.suggestion, // New
    );
  }

  bool get isLocationValid => originLat != null && destLat != null;
  bool get isTimeValid => departureTime != null;
}

class OfferRideController
    extends AutoDisposeFamilyNotifier<OfferRideState, String> {
  late final String _driverId;

  @override
  OfferRideState build(String arg) {
    _driverId = arg;
    return OfferRideState();
  }

  void setOrigin(double lat, double lng, String label) {
    state = state.copyWith(originLat: lat, originLng: lng, originLabel: label);
  }

  void setDest(double lat, double lng, String label) {
    state = state.copyWith(destLat: lat, destLng: lng, destLabel: label);
  }

  void setDepartureTime(DateTime dt) {
    state = state.copyWith(departureTime: dt, suggestion: null);
    _checkSmartDeparture(dt);
  }

  Future<void> _checkSmartDeparture(DateTime dt) async {
    if (state.originLat == null || state.originLng == null) return;

    state = state.copyWith(isAnalyzingTime: true);
    try {
      final res = await ref.read(tripsRepoProvider).fetchDriverIncentives(
            lat: state.originLat!,
            lng: state.originLng!,
            time: dt,
          );
      state = state.copyWith(
        isAnalyzingTime: false,
        suggestion: res.suggestion,
      );
    } catch (e) {
      state = state.copyWith(isAnalyzingTime: false);
      debugPrint('Error checking smart departure: $e');
    }
  }

  void applySuggestion() {
    if (state.suggestion == null) return;
    state = state.copyWith(
      departureTime: state.suggestion!.suggestedTime,
      suggestion: null,
    );
  }

  void addWaypoint({
    required double lat,
    required double lng,
    required String label,
  }) {
    if (state.waypoints.length >= 3) return;
    final next = [
      ...state.waypoints,
      TripWaypoint(lat: lat, lng: lng, label: label),
    ];
    state = state.copyWith(waypoints: next);
  }

  void removeWaypoint(int index) {
    if (index < 0 || index >= state.waypoints.length) return;
    final next = [...state.waypoints]..removeAt(index);
    state = state.copyWith(waypoints: next);
  }

  void setSeats(int seats) {
    state = state.copyWith(seats: seats);
  }

  void toggleWomenOnly(bool val) {
    state = state.copyWith(womenOnly: val);
  }

  void togglePreference(String key, bool selected) {
    final next = <String>{...state.ridePreferences};
    if (selected) {
      next.add(key);
    } else {
      next.remove(key);
    }
    state = state.copyWith(ridePreferences: next);
  }

  void toggleBusinessRide(bool enabled) {
    state = state.copyWith(
      isBusinessRide: enabled,
      companyName: enabled ? state.companyName : null,
    );
  }

  void setCompanyName(String value) {
    state =
        state.copyWith(companyName: value.trim().isEmpty ? null : value.trim());
  }

  void toggleCampusRide(bool enabled) {
    state = state.copyWith(
      isCampusRide: enabled,
      campusName: enabled ? state.campusName : null,
    );
  }

  void setCampusName(String value) {
    state =
        state.copyWith(campusName: value.trim().isEmpty ? null : value.trim());
  }

  void toggleEventRide(bool enabled) {
    state = state.copyWith(
      isEventRide: enabled,
      eventLabel: enabled ? state.eventLabel : null,
    );
  }

  void setEventLabel(String value) {
    state =
        state.copyWith(eventLabel: value.trim().isEmpty ? null : value.trim());
  }

  void toggleFazaRide(bool enabled) {
    state = state.copyWith(isFazaRide: enabled);
  }

  static List<String> buildRideTags({
    required bool womenOnly,
    required Set<String> ridePreferences,
    bool isBusinessRide = false,
    String? companyName,
    bool isCampusRide = false,
    String? campusName,
    bool isEventRide = false,
    String? eventLabel,
    bool isFazaRide = false,
  }) {
    final tags = <String>{...ridePreferences};
    if (isFazaRide) {
      tags.add('faza');
    }
    if (womenOnly) {
      tags.add('women_only');
    }
    if (isBusinessRide) {
      tags.add('business_ride');
      final normalized = (companyName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');
      if (normalized.isNotEmpty) {
        tags.add('company:$normalized');
      }
    }
    if (isCampusRide) {
      tags.add('campus_ride');
      final normalized = (campusName ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');
      if (normalized.isNotEmpty) {
        tags.add('campus:$normalized');
      }
    }
    if (isEventRide) {
      tags.add('event_ride');
      final normalized = (eventLabel ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');
      if (normalized.isNotEmpty) {
        tags.add('event:$normalized');
      }
    }
    return tags.toList()..sort();
  }

  Future<void> submit() async {
    if (!state.isLocationValid || !state.isTimeValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final trip = Trip(
        id: '', // let server gen
        driverId: _driverId,
        originLat: state.originLat!,
        originLng: state.originLng!,
        destLat: state.destLat!,
        destLng: state.destLng!,
        originLabel: state.originLabel,
        destLabel: state.destLabel,
        // polyline: null, // Could fetch route here
        departureTime: state.departureTime!,
        waypoints: state.waypoints,
        seatsTotal: state.seats,
        seatsAvailable: state.seats,
        womenOnly: state.womenOnly,
        isKidsRide: false,
        status: TripStatus.planned,
        isRecurring: state.isRecurring,
        tags: buildRideTags(
          womenOnly: state.womenOnly,
          ridePreferences: state.ridePreferences,
          isBusinessRide: state.isBusinessRide,
          companyName: state.companyName,
          isCampusRide: state.isCampusRide,
          campusName: state.campusName,
          isEventRide: state.isEventRide,
          eventLabel: state.eventLabel,
          isFazaRide: state.isFazaRide,
        ),
      );

      await ref.read(tripsRepoProvider).createTrip(trip);
      state = state.copyWith(isLoading: false);
      // Navigation should be handled by listener in UI
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorMapper.map(e));
      rethrow;
    }
  }
}

final offerRideControllerProvider = NotifierProvider.autoDispose
    .family<OfferRideController, OfferRideState, String>(
  OfferRideController.new,
);
