import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, resident, guard, unknown }

class AuthService {
  static const String baseUrl = "http://marianela-api.test/api";
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static String? _token;
  static Map<String, dynamic>? _user;

  static String? get token => _token;
  static Map<String, dynamic>? get user => _user;

  static UserRole get role {
    final r = (_user?['role'] as String?)?.toLowerCase();
    switch (r) {
      case 'admin':
        return UserRole.admin;
      case 'resident':
        return UserRole.resident;
      case 'guard':
        return UserRole.guard;
      default:
        return UserRole.unknown;
    }
  }

  static bool get isLoggedIn => _token != null;

  // Cargar token y user guardados al iniciar la app
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    _user = rawUser != null
        ? jsonDecode(rawUser) as Map<String, dynamic>
        : null;
  }

  static Future<void> _saveSession(
    String token,
    Map<String, dynamic> user,
  ) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<void> _clearSession() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Login
  static Future<bool> login(String usuario, String password) async {
    final url = Uri.parse("$baseUrl/login"); // tu API: POST /api/login
    final res = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': usuario, 'password': password},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null && token.isNotEmpty && user != null) {
        await _saveSession(token, user);
        return true;
      }
    }
    return false;
  }

  /// Logout
  static Future<bool> logout() async {
    if (_token == null) {
      await _clearSession();
      return true;
    }
    final url = Uri.parse("$baseUrl/logout");
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 200 || res.statusCode == 401) {
      await _clearSession();
      return true;
    }
    return false;
  }

  /// Headers con Authorization para otros endpoints
  static Map<String, String> authHeaders([Map<String, String>? extra]) => {
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
    ...?extra,
  };
}
