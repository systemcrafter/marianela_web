import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/screens/home/shared/home_card.dart';
import 'package:marianela_web/screens/home/shared/home_header_decoration.dart';
import 'package:marianela_web/screens/home/shared/home_bottom_nav.dart';
import 'package:marianela_web/screens/guard/checkin_invites.dart';

class HomeScreenGuard extends StatelessWidget {
  const HomeScreenGuard({super.key});

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
                children: [
                  HomeCard(
                    title: 'Registrar visita',
                    icon: Icons.how_to_reg,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckinInvitesScreen(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    title: 'Bitácora',
                    icon: Icons.fact_check,
                    onTap: () {},
                  ),
                  HomeCard(
                    title: 'Alertas',
                    icon: Icons.emergency_share,
                    onTap: () {},
                  ),
                  HomeCard(
                    title: 'Escanear QR',
                    icon: Icons.qr_code_scanner,
                    onTap: () {},
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
