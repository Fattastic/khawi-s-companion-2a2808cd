import 'package:flutter/material.dart';

class TripService extends ChangeNotifier {
  // Mock listing active trips
  final List<String> _activeTrips = [];

  List<String> get activeTrips => _activeTrips;

  Future<void> requestRide(String destination) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _activeTrips.add("Trip to $destination");
    notifyListeners();
  }

  Future<void> cancelTrip(int index) async {
    if (index < _activeTrips.length) {
      _activeTrips.removeAt(index);
      notifyListeners();
    }
  }
}
