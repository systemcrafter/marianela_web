import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'package:marianela_web/screens/login/login_screen.dart';
import 'package:marianela_web/screens/home/role_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const MarianelaApp());
}

class MarianelaApp extends StatelessWidget {
  const MarianelaApp({super.key});
  static const kBrand = Color(0xFF7A6CF7);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marianela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kBrand, useMaterial3: true),
      initialRoute: AuthService.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(), // tu pantalla actual
        '/home': (_) => const RoleRouter(),
      },
    );
  }
}
