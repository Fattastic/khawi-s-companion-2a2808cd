import 'package:khawi_flutter/features/trips/domain/trip.dart';

Uri buildGoogleMapsNavigationUri(Trip trip) {
  final waypointValues = trip.waypoints
      .map((stop) => '${stop.lat},${stop.lng}')
      .toList(growable: false);

  return Uri.https(
    'www.google.com',
    '/maps/dir/',
    {
      'api': '1',
      'destination': '${trip.destLat},${trip.destLng}',
      'travelmode': 'driving',
      if (waypointValues.isNotEmpty) 'waypoints': waypointValues.join('|'),
    },
  );
}

Uri buildAppleMapsNavigationUri(Trip trip) {
  return Uri.https(
    'maps.apple.com',
    '/',
    {
      'daddr': '${trip.destLat},${trip.destLng}',
      'dirflg': 'd',
    },
  );
}

Uri buildWazeNavigationUri(Trip trip) {
  return Uri.parse(
    'https://waze.com/ul?ll=${trip.destLat},${trip.destLng}&navigate=yes',
  );
}
