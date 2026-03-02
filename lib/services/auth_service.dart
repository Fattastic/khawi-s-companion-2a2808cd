import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  Future<bool> login(String phoneNumber, String code) async {
    // Mock network delay
    await Future<void>.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userId = "user_123";
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }

  Future<bool> verifyCode(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return code == "1234";
  }
}
