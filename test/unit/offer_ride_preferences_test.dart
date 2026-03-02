import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/trips/presentation/controllers/offer_ride_controller.dart';

void main() {
  group('OfferRideController.buildRideTags', () {
    test('includes women_only when enabled', () {
      final tags = OfferRideController.buildRideTags(
        womenOnly: true,
        ridePreferences: const {'quiet'},
      );

      expect(tags, containsAll(<String>['quiet', 'women_only']));
    });

    test('omits women_only when disabled', () {
      final tags = OfferRideController.buildRideTags(
        womenOnly: false,
        ridePreferences: const {'quiet', 'cold_ac'},
      );

      expect(tags, isNot(contains('women_only')));
      expect(tags, containsAll(<String>['quiet', 'cold_ac']));
    });

    test('returns stable sorted output', () {
      final tags = OfferRideController.buildRideTags(
        womenOnly: false,
        ridePreferences: const {'no_smoking', 'cold_ac', 'quiet'},
      );

      expect(tags, equals(<String>['cold_ac', 'no_smoking', 'quiet']));
    });

    test('adds business tags when business ride enabled', () {
      final tags = OfferRideController.buildRideTags(
        womenOnly: false,
        ridePreferences: const {'quiet'},
        isBusinessRide: true,
        companyName: 'ACME Corp',
      );

      expect(tags, contains('business_ride'));
      expect(tags, contains('company:acme_corp'));
      expect(tags, contains('quiet'));
    });

    test('adds campus and event tags when enabled', () {
      final tags = OfferRideController.buildRideTags(
        womenOnly: false,
        ridePreferences: const {'quiet'},
        isCampusRide: true,
        campusName: 'King Saud University',
        isEventRide: true,
        eventLabel: 'Riyadh Season',
      );

      expect(tags, contains('campus_ride'));
      expect(tags, contains('campus:king_saud_university'));
      expect(tags, contains('event_ride'));
      expect(tags, contains('event:riyadh_season'));
    });
  });
}
