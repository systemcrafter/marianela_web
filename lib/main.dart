import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'core/services/auth_service.dart';
import 'core/services/api_client.dart';
import 'package:marianela_web/screens/login/login_screen.dart';
import 'package:marianela_web/screens/home/role_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();

  // 🔎 Valida token contra /me
  final loggedIn = await AuthService.me();

  // 🩹 Fix global de viewport y escalado (Samsung, Huawei, etc.)
  html.document.head?.append(
    html.MetaElement()
      ..name = 'viewport'
      ..content =
          'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
  );

  runApp(MarianelaApp(startLoggedIn: loggedIn));
}

class MarianelaApp extends StatelessWidget {
  const MarianelaApp({super.key, this.startLoggedIn = false});
  final bool startLoggedIn;

  static const kBrand = Color(0xFF7A6CF7);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residencial Marianela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kBrand, useMaterial3: true),
      navigatorKey: navigatorKey, // 👈 mantiene navegación global
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          // 🔧 Evita zoom o escalado de texto en móviles Samsung
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      initialRoute: startLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const RoleRouter(),
      },
    );
  }
}
