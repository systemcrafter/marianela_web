import 'package:flutter/material.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class SupportRequiredScreen extends StatelessWidget {
  const SupportRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Residencial Marianela"),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7A6CF7), Color(0xFF9B59F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const WaveHeader(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.deepPurple.shade400,
                    size: 80,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Acceso Restringido',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Esta es una aplicación cerrada. En caso de requerir soporte, '
                    'por favor contacte con la administración del residencial para que se realice la autenticación '
                    'respectiva y se otorguen los permisos necesarios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A6CF7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Volver al inicio',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
