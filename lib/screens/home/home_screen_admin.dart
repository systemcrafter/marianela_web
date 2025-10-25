import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/screens/home/shared/home_card.dart';
import 'package:marianela_web/screens/home/shared/home_header_decoration.dart';
import 'package:marianela_web/screens/home/shared/home_bottom_nav.dart';
import 'package:marianela_web/screens/admin/payments_report.dart';
import 'package:marianela_web/screens/admin/tickets_list.dart';
import 'package:marianela_web/screens/admin/users_list.dart';
import 'package:marianela_web/screens/admin/period_open.dart';

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
                  // Ajusta el aspect ratio automáticamente según el ancho disponible
                  final aspectRatio = constraints.maxWidth < 600 ? 1.3 : 2.0;

                  final items = [
                    {
                      'title': 'Usuarios',
                      'icon': Icons.group,
                      'screen': const UsersListScreen(),
                    },
                    {
                      'title': 'Pagos / Estados',
                      'icon': Icons.receipt_long,
                      'screen': const PaymentsReportScreen(),
                    },
                    {
                      'title': 'Tickets abiertos',
                      'icon': Icons.support_agent,
                      'screen': const TicketsListScreen(),
                    },
                    {
                      'title': 'Abrir periodo',
                      'icon': Icons.calendar_month_outlined,
                      'screen': const PeriodOpenScreen(),
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
                          Navigator.of(context).push(
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
        role: 'admin',
        onLogout: () => _logout(context),
      ),
    );
  }
}
