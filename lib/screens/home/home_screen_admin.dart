import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/screens/home/shared/home_card.dart';
import 'package:marianela_web/screens/home/shared/home_header_decoration.dart';
import 'package:marianela_web/screens/home/shared/home_bottom_nav.dart';

class HomeScreenAdmin extends StatelessWidget {
  const HomeScreenAdmin({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await AuthService.logout();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cerrar sesión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthService.user?['role'] ?? ''; // ← viene del backend

    return Scaffold(
      body: Column(
        children: [
          HomeHeaderDecoration(height: 120, title: "Bienvenid@ $role"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
                children: const [
                  HomeCard(title: 'Usuarios', icon: Icons.group, onTap: _noop),
                  HomeCard(
                    title: 'Pagos / Estados',
                    icon: Icons.receipt_long,
                    onTap: _noop,
                  ),
                  HomeCard(
                    title: 'Incidencias',
                    icon: Icons.report,
                    onTap: _noop,
                  ),
                  HomeCard(
                    title: 'Accesos / Visitas',
                    icon: Icons.verified_user,
                    onTap: _noop,
                  ),
                  HomeCard(
                    title: 'Configuración',
                    icon: Icons.settings,
                    onTap: _noop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(onLogout: () => _logout(context)),
    );
  }
}

void _noop() {}
