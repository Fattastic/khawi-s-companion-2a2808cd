import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'khawi_locale'; // 'ar' or 'en'

  // Persisted user preference (null means never chosen)
  Locale? _preferredLocale;

  // Temporary override (used on Splash only)
  Locale? _lockedLocale;

  LocaleProvider() {
    _load();
  }

  Locale get effectiveLocale =>
      _lockedLocale ?? _preferredLocale ?? const Locale('ar');

  bool get hasUserChosenLocale => _preferredLocale != null;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'en' || code == 'ar') {
      _preferredLocale = Locale(code!);
    }
    notifyListeners();
  }

  void lockToArabicForSplash() {
    _lockedLocale = const Locale('ar');
    notifyListeners();
  }

  void unlockAfterSplash() {
    _lockedLocale = null;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'ar' && locale.languageCode != 'en') return;
    _preferredLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
