import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/screens/home/shared/home_card.dart';
import 'package:marianela_web/screens/home/shared/home_header_decoration.dart';
import 'package:marianela_web/screens/home/shared/home_bottom_nav.dart';
import 'package:marianela_web/screens/resident/accounts_pending_screen.dart';
import 'package:marianela_web/screens/resident/invites.dart';
import 'package:marianela_web/screens/resident/invites_history.dart';
import 'package:marianela_web/screens/resident/ticket_form_screen.dart';
import 'package:marianela_web/screens/resident/ticket_history.dart';

class HomeScreenResident extends StatelessWidget {
  const HomeScreenResident({super.key});

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
    final name = AuthService.user?['name'] ?? '';

    return Scaffold(
      body: Column(
        children: [
          HomeHeaderDecoration(height: 120, title: "Bienvenid(a) $name"),
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
                    title: 'Autorizar visitas',
                    icon: Icons.verified_user,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InviteFormScreen(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    title: 'Historial Autorizaciones',
                    icon: Icons.list,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvitesHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    title: 'Consulta Pendientes',
                    icon: Icons.receipt_long,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountsPendingScreen(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    title: 'Reportar incidencia',
                    icon: Icons.support_agent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TicketFormScreen(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    title: 'Historial incidencias',
                    icon: Icons.list_alt_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TicketsHistoryScreen(),
                        ),
                      );
                    },
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
