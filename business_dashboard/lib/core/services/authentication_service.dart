import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/api_exception.dart';
import 'dart:convert';

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  static const String _tokenKey = 'authToken';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'isRemembered';

  String? _token;
  Map<String, dynamic>? _userData;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
    }
    _isAuthenticated = _token != null;
  }

  Future<bool> login(String email, String password) async {
    if (email == 'admin@business.com' && password == 'admin123') {
      _userData = {
        'email': email,
        'role': 'admin',
        'token': 'mock-jwt-token-12345',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_userData));
      _token = _userData?['token'];
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_rememberMeKey);
    _token = null;
    _isAuthenticated = false;
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  String? get userEmail => _userData?['email'];
  String? get userRole => _userData?['role'];
} 