import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  // String
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  // Double
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);

  // Bool
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  // StringList
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // Remove & Clear
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Check if key exists
  bool containsKey(String key) => _prefs.containsKey(key);
}
