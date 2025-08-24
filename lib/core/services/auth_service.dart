import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://marianela-api.test/api";
  static const String _tokenKey = 'auth_token';
  static String? _token;

  static String? get token => _token;
  static bool get isLoggedIn => _token != null;

  // Cargar token guardado al iniciar la app
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Login
  static Future<bool> login(String usuario, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final res = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': usuario, // tu API usa 'email'
        'password': password,
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
        return true;
      }
    }
    return false;
  }

  /// Logout
  static Future<bool> logout() async {
    if (_token == null) return false;

    final url = Uri.parse("$baseUrl/logout");
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );

    // Si el backend respondió OK o 401 (token ya inválido), limpia local
    if (res.statusCode == 200 || res.statusCode == 401) {
      await _clearToken();
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
