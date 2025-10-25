// home_screen_resident.dart
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
import 'package:marianela_web/screens/resident/payment_screen.dart';
import 'package:marianela_web/screens/resident/user_info.dart';

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
              // 🔧 Se reemplazó GridView.count por LayoutBuilder + GridView.builder
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ajusta el aspect ratio automáticamente según el ancho disponible
                  final aspectRatio = constraints.maxWidth < 600 ? 1.3 : 2.0;

                  final items = [
                    {
                      'title': 'Autorizar visitas',
                      'icon': Icons.verified_user,
                      'screen': const InviteFormScreen(),
                    },
                    {
                      'title': 'Historial Autorizaciones',
                      'icon': Icons.list,
                      'screen': const InvitesHistoryScreen(),
                    },
                    {
                      'title': 'Consulta Pendientes',
                      'icon': Icons.receipt_long,
                      'screen': const AccountsPendingScreen(),
                    },
                    {
                      'title': 'Reportar pago',
                      'icon': Icons.payment,
                      'screen': const PaymentScreen(),
                    },
                    {
                      'title': 'Reportar incidencia',
                      'icon': Icons.support_agent,
                      'screen': const TicketFormScreen(),
                    },
                    {
                      'title': 'Historial incidencias',
                      'icon': Icons.list_alt_outlined,
                      'screen': const TicketsHistoryScreen(),
                    },
                    {
                      'title': 'Mi Perfil',
                      'icon': Icons.person_pin,
                      'screen': const UserInfoScreen(),
                    },
                  ];

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return HomeCard(
                        title: item['title'] as String,
                        icon: item['icon'] as IconData,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item['screen'] as Widget,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        role: 'resident',
        onLogout: () => _logout(context),
      ),
    );
  }
}
