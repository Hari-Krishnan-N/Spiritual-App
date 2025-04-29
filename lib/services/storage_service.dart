import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to handle local storage operations using SharedPreferences
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    if (!_isInitialized) await initialize();
    return await _prefs.setString(key, value);
  }

  /// Get a string value
  String getString(String key, {String defaultValue = ''}) {
    if (!_isInitialized) return defaultValue;
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    if (!_isInitialized) await initialize();
    return await _prefs.setInt(key, value);
  }

  /// Get an integer value
  int getInt(String key, {int defaultValue = 0}) {
    if (!_isInitialized) return defaultValue;
    return _prefs.getInt(key) ?? defaultValue;
  }

  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    if (!_isInitialized) await initialize();
    return await _prefs.setBool(key, value);
  }

  /// Get a boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    if (!_isInitialized) return defaultValue;
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Save a string list
  Future<bool> setStringList(String key, List<String> value) async {
    if (!_isInitialized) await initialize();
    return await _prefs.setStringList(key, value);
  }

  /// Get a string list
  List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    if (!_isInitialized) return defaultValue;
    return _prefs.getStringList(key) ?? defaultValue;
  }

  /// Save a JSON object (converted to string)
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    if (!_isInitialized) await initialize();
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// Get a JSON object (parsed from string)
  Map<String, dynamic> getJson(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    if (!_isInitialized) return defaultValue;

    final jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return defaultValue;
    }

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON from storage: $e');
      return defaultValue;
    }
  }

  /// Get an object list from JSON
  List<T> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson, {
    List<T> defaultValue = const [],
  }) {
    if (!_isInitialized) return defaultValue;

    final jsonStrings = _prefs.getStringList(key);
    if (jsonStrings == null || jsonStrings.isEmpty) {
      return defaultValue;
    }

    try {
      return jsonStrings
          .map((str) => fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing object list from storage: $e');
      return defaultValue;
    }
  }

  /// Save an object list to JSON
  Future<bool> setObjectList<T>(
    String key,
    List<T> objects,
    Map<String, dynamic> Function(T obj) toJson,
  ) async {
    if (!_isInitialized) await initialize();

    final jsonStrings = objects.map((obj) => jsonEncode(toJson(obj))).toList();

    return await _prefs.setStringList(key, jsonStrings);
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    if (!_isInitialized) await initialize();
    return await _prefs.remove(key);
  }

  /// Clear all storage
  Future<bool> clear() async {
    if (!_isInitialized) await initialize();
    return await _prefs.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    if (!_isInitialized) return false;
    return _prefs.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    if (!_isInitialized) return {};
    return _prefs.getKeys();
  }
}
