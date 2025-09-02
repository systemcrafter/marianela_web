import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'package:marianela_web/screens/login/login_screen.dart';
import 'package:marianela_web/screens/home/role_router.dart';
import 'core/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();

  // 🔎 Valida token contra /me
  final loggedIn = await AuthService.me();

  runApp(MarianelaApp(startLoggedIn: loggedIn));
}

class MarianelaApp extends StatelessWidget {
  const MarianelaApp({super.key, this.startLoggedIn = false});
  final bool startLoggedIn;

  static const kBrand = Color(0xFF7A6CF7);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marianela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kBrand, useMaterial3: true),
      navigatorKey: navigatorKey, // 👈 ahora tu app puede redirigir globalmente
      initialRoute: startLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const RoleRouter(),
      },
    );
  }
}
