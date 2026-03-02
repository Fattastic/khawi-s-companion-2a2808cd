import 'package:shared_preferences/shared_preferences.dart';

class FavoriteDriversService {
  static const _keyPrefix = 'favorite_driver_ids';

  String _key(String? userId) =>
      userId == null || userId.isEmpty ? _keyPrefix : '$_keyPrefix:$userId';

  Future<Set<String>> getFavorites({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key(userId)) ?? const <String>[];
    return values.toSet();
  }

  Future<void> setFavorites(Set<String> ids, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key(userId), ids.toList()..sort());
  }

  Future<bool> toggleFavorite(String driverId, {String? userId}) async {
    final current = await getFavorites(userId: userId);
    final added = !current.contains(driverId);
    if (added) {
      current.add(driverId);
    } else {
      current.remove(driverId);
    }
    await setFavorites(current, userId: userId);
    return added;
  }

  Future<bool> isFavorite(String driverId, {String? userId}) async {
    final current = await getFavorites(userId: userId);
    return current.contains(driverId);
  }
}
