import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/wave_header.dart'; // 👈 importa el header reutilizable

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await AuthService.logout();
    if (!context.mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al cerrar sesión")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // cuerpo detrás del AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WaveHeader(
              height: 240,
            ), // 👈 mismo arte que en login (sin logo)
            Transform.translate(
              offset: const Offset(0, -24), // “sube” un poco el contenido
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: const Text(
                      "Bienvenido a Residencial Marianela",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
