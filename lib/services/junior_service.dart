import 'package:flutter/material.dart';

class JuniorService extends ChangeNotifier {
  bool _isPlaying = false;
  int _dailyPoints = 120;
  String? _currentRideStatus; // null, 'waiting', 'in_ride', 'arrived'

  bool get isPlaying => _isPlaying;
  int get dailyPoints => _dailyPoints;
  String? get currentRideStatus => _currentRideStatus;

  // Mock safety contacts
  List<Map<String, String>> get safetyContacts => [
        {"name": "Mom", "phone": "0501112222"},
        {"name": "Dad", "phone": "0503334444"},
      ];

  void toggleGameMode() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void startRideSimulation() {
    _currentRideStatus = 'waiting';
    notifyListeners();
    // Simulate ride progression
    Future.delayed(const Duration(seconds: 3), () {
      _currentRideStatus = 'in_ride';
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 8), () {
      _currentRideStatus = null;
      _dailyPoints += 50; // Award points for ride completion
      notifyListeners();
    });
  }
}
