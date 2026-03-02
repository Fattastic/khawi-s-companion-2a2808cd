import 'package:flutter/material.dart';

class DriverService extends ChangeNotifier {
  bool _isOnline = false;
  final double _weeklyEarnings = 350.50;
  final int _ridesToday = 4;

  bool get isOnline => _isOnline;
  double get weeklyEarnings => _weeklyEarnings;
  int get ridesToday => _ridesToday;

  void toggleStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  // Mock list of request summaries
  List<Map<String, dynamic>> get urgentRequests => _isOnline
      ? [
          {
            "passenger": "Khalid",
            "distance": "0.5 km",
            "destination": "Riyadh Front",
            "points": 150,
          },
          {
            "passenger": "Sarah",
            "distance": "1.2 km",
            "destination": "Panorama Mall",
            "points": 200,
          },
        ]
      : [];
}
