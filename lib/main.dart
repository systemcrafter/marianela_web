import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init(); // carga token persistido
  runApp(const MarianelaApp());
}

class MarianelaApp extends StatelessWidget {
  const MarianelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residencial Marianela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AuthService.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
