import 'dart:math';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

/// Mock implementation of [MatchingGateway] for testing and development.
///
/// Returns deterministic fake data without network calls.
/// Use this for:
/// - Unit and widget tests
/// - Development without backend
/// - Demo/presentation mode
class MockMatchingGateway implements MatchingGateway {
  MockMatchingGateway({this.delayMs = 200});

  /// Simulated network delay in milliseconds.
  final int delayMs;

  final _random = Random(42); // Fixed seed for deterministic results

  /// Get mock trips with dynamic departure times.
  static List<Trip> _getMockTrips() {
    final now = DateTime.now();
    return [
      Trip(
        id: 'mock_trip_1',
        driverId: 'driver_1',
        originLat: 24.7136,
        originLng: 46.6753,
        originLabel: 'King Fahd District',
        destLat: 24.7746,
        destLng: 46.7384,
        destLabel: 'Olaya District',
        departureTime: now.add(const Duration(hours: 1)),
        seatsTotal: 4,
        seatsAvailable: 3,
        womenOnly: false,
        isKidsRide: false,
        isRecurring: true,
        tags: const ['trusted', 'regular'],
        status: TripStatus.planned,
        driverTrustScore: 85,
        driverTrustBadge: 'gold',
        driverJuniorTrusted: true,
      ),
      Trip(
        id: 'mock_trip_2',
        driverId: 'driver_2',
        originLat: 24.7256,
        originLng: 46.6853,
        originLabel: 'Sulaimaniyah',
        destLat: 24.7636,
        destLng: 46.7284,
        destLabel: 'Al Malaz',
        departureTime: now.add(const Duration(hours: 2)),
        seatsTotal: 3,
        seatsAvailable: 2,
        womenOnly: true,
        isKidsRide: false,
        isRecurring: false,
        tags: const ['women-only', 'verified'],
        status: TripStatus.planned,
        driverTrustScore: 92,
        driverTrustBadge: 'platinum',
        driverJuniorTrusted: true,
      ),
      Trip(
        id: 'mock_trip_3',
        driverId: 'driver_3',
        originLat: 24.7016,
        originLng: 46.6653,
        originLabel: 'Al Naseem',
        destLat: 24.7846,
        destLng: 46.7484,
        destLabel: 'Al Rabwah',
        departureTime: now.add(const Duration(hours: 3)),
        seatsTotal: 5,
        seatsAvailable: 4,
        womenOnly: false,
        isKidsRide: true,
        isRecurring: true,
        tags: const ['kids-friendly', 'regular'],
        status: TripStatus.planned,
        driverTrustScore: 70,
        driverTrustBadge: 'silver',
        driverJuniorTrusted: false,
      ),
    ];
  }

  static const _explanationTags = [
    'Same neighborhood',
    'Compatible schedule',
    'Similar route',
    'High-rated driver',
    'Trusted for juniors',
    'Frequent commuter',
    'Women-only option',
  ];

  @override
  Future<List<Match>> smartMatch(MatchRequest request) async {
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    var trips = _getMockTrips();

    // Filter by women-only preference
    if (request.womenOnly == true) {
      trips = trips.where((t) => t.womenOnly).toList();
    }

    // Limit results
    if (trips.length > request.maxResults) {
      trips = trips.take(request.maxResults).toList();
    }

    // Generate mock scores
    return trips.asMap().entries.map((entry) {
      final index = entry.key;
      final trip = entry.value;

      // Higher scores for earlier trips (simulating better matches)
      final baseScore = 95 - (index * 10);
      final score = (baseScore + _random.nextInt(10)).clamp(50, 100);

      // Random tags
      final tagCount = 2 + _random.nextInt(3);
      final tags =
          (_explanationTags.toList()..shuffle(_random)).take(tagCount).toList();

      return Match(
        trip: trip,
        score: score,
        explanationTags: tags,
        acceptProbability: score / 100.0 * (0.8 + _random.nextDouble() * 0.2),
      );
    }).toList();
  }

  @override
  Future<BundleResult?> bundleStops({
    required String tripId,
    required List<String> passengerIds,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    if (passengerIds.isEmpty) return null;

    // Generate mock stops
    final stops = <BundleStop>[];
    for (final passengerId in passengerIds) {
      stops.add(
        BundleStop(
          type: 'pickup',
          label:
              'Pickup ${passengerId.substring(0, min(4, passengerId.length))}',
          lat: 24.7136 + _random.nextDouble() * 0.05,
          lng: 46.6753 + _random.nextDouble() * 0.05,
          passengerId: passengerId,
        ),
      );
    }
    for (final passengerId in passengerIds) {
      stops.add(
        BundleStop(
          type: 'dropoff',
          label:
              'Dropoff ${passengerId.substring(0, min(4, passengerId.length))}',
          lat: 24.7746 + _random.nextDouble() * 0.05,
          lng: 46.7384 + _random.nextDouble() * 0.05,
          passengerId: passengerId,
        ),
      );
    }

    return BundleResult(
      rankScore: 85 + _random.nextInt(15),
      stops: stops,
    );
  }

  @override
  Future<Map<String, Match>> scoreTrips({
    required List<Trip> trips,
    required MatchRequest request,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final result = <String, Match>{};

    for (var i = 0; i < trips.length; i++) {
      final trip = trips[i];
      final baseScore = 90 - (i * 5);
      final score = (baseScore + _random.nextInt(15)).clamp(40, 100);

      final tagCount = 2 + _random.nextInt(3);
      final tags =
          (_explanationTags.toList()..shuffle(_random)).take(tagCount).toList();

      result[trip.id] = Match(
        trip: trip,
        score: score,
        explanationTags: tags,
        acceptProbability: score / 100.0,
      );
    }

    return result;
  }
}
