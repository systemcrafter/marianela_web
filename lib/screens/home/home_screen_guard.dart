import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/screens/home/shared/home_card.dart';
import 'package:marianela_web/screens/home/shared/home_header_decoration.dart';
import 'package:marianela_web/screens/home/shared/home_bottom_nav.dart';
import 'package:marianela_web/screens/guard/checking_invites.dart';
import 'package:marianela_web/screens/guard/list_invites.dart';
import 'package:marianela_web/screens/guard/ticket_form_screen_guard.dart';

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
    final name = AuthService.user?['name'] ?? '';

    return Scaffold(
      body: Column(
        children: [
          HomeHeaderDecoration(height: 120, title: "Bienvenid@ $name"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              // 🔧 Se reemplazó GridView.count por LayoutBuilder + GridView.builder
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ajusta el aspect ratio dinámicamente según el ancho disponible
                  final aspectRatio = constraints.maxWidth < 600 ? 1.3 : 2.0;

                  final items = [
                    {
                      'title': 'Registrar visita',
                      'icon': Icons.how_to_reg,
                      'screen': const CheckinInvitesScreen(),
                    },
                    {
                      'title': 'Bitácora',
                      'icon': Icons.fact_check,
                      'screen': const ListInvitesScreen(),
                    },
                    {
                      'title': 'Reportar incidencia',
                      'icon': Icons.support_agent,
                      'screen': const TicketFormScreenGuard(),
                    },
                    {
                      'title': 'Escanear QR',
                      'icon': Icons.qr_code_scanner,
                      'screen': null, // Placeholder sin acción
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
                          final screen = item['screen'];
                          if (screen != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => screen as Widget,
                              ),
                            );
                          }
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
        role: 'guard',
        onLogout: () => _logout(context),
      ),
    );
  }
}
