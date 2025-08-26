import 'package:flutter/material.dart';

/// Barra inferior simple con 4 botones.
/// El índice 3 (último) dispara onLogout().
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onChanged,
    required this.onLogout,
  });

  final int currentIndex; // opcional (para resaltar selección)
  final ValueChanged<int>? onChanged; // taps 0,1,2
  final Future<void> Function() onLogout; // tap 3

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex.clamp(0, 2), // dejamos el 0 seleccionado
        onTap: (i) async {
          if (i == 3) {
            await onLogout();
          } else {
            onChanged?.call(i);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Incidencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
        ],
      ),
    );
  }
}
