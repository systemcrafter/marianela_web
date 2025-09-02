import 'package:http/http.dart' as http;
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/env.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse("${Env.apiBaseUrl}$endpoint");
    final res = await http.get(url, headers: AuthService.authHeaders());
    if (res.statusCode == 401) {
      await AuthService.logout();
      _redirectToLogin();
    }
    return res;
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse("${Env.apiBaseUrl}$endpoint");
    final res = await http.post(
      url,
      headers: AuthService.authHeaders(),
      body: body,
    );
    if (res.statusCode == 401) {
      await AuthService.logout();
      _redirectToLogin();
    }
    return res;
  }

  static void _redirectToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}

// 🔑 Navigator global para poder redirigir desde cualquier parte
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
