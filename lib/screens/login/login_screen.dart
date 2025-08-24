import 'package:flutter/material.dart';
import 'widgets/header_decoration.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cabecera morada con ola
                LoginHeader(height: isWide ? 360 : 320),

                // Tarjeta flotante con el formulario
                Transform.translate(
                  offset: const Offset(0, -30), // ⬅️ antes: -70
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                          ), // ⬅️ baja un poco más
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 26,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  LoginForm(), // usa tu lógica actual de AuthService
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
