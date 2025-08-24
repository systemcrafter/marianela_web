import 'package:flutter/material.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/home/home_screen.dart'; // 👈 importar Home

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home'; // 👈 definir constante

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(), // 👈 registrar ruta
  };
}
