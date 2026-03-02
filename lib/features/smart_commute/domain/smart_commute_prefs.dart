import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';

class SmartCommutePrefs {
  const SmartCommutePrefs({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.maxResults,
    required this.womenOnly,
    this.departureTime,
  });

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final int maxResults;
  final bool womenOnly;
  final DateTime? departureTime;

  MatchRequest toMatchRequest() {
    return MatchRequest(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      departureTime: departureTime,
      womenOnly: womenOnly ? true : null,
      maxResults: maxResults,
    );
  }
}

SmartCommutePrefs defaultSmartCommutePrefs() {
  return SmartCommutePrefs(
    originLat: 24.7136,
    originLng: 46.6753,
    destLat: 24.7746,
    destLng: 46.7384,
    maxResults: 10,
    womenOnly: false,
    departureTime: DateTime.now().add(const Duration(minutes: 30)),
  );
}
