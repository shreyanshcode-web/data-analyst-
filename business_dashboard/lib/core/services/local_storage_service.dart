import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return _prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return _prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return _prefs.setBool(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return _prefs.setDouble(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return _prefs.setStringList(key, value);
  }

  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    return _prefs.setString(key, jsonEncode(value));
  }

  String? getString(String key) {
    _ensureInitialized();
    return _prefs.getString(key);
  }

  int? getInt(String key) {
    _ensureInitialized();
    return _prefs.getInt(key);
  }

  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs.getBool(key);
  }

  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs.getDouble(key);
  }

  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs.getStringList(key);
  }

  Map<String, dynamic>? getObject(String key) {
    _ensureInitialized();
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding JSON for key $key: $e');
      return null;
    }
  }

  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return _prefs.remove(key);
  }

  Future<bool> clear() async {
    await _ensureInitialized();
    return _prefs.clear();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }
} 