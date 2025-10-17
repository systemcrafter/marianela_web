import 'package:flutter/material.dart';

// Admin
import 'package:marianela_web/screens/admin/users_list.dart';
import 'package:marianela_web/screens/admin/tickets_list.dart';
import 'package:marianela_web/screens/admin/payments_report.dart';

// Guard
import 'package:marianela_web/screens/guard/checking_invites.dart';
import 'package:marianela_web/screens/guard/ticket_form_screen_guard.dart';
import 'package:marianela_web/screens/guard/list_invites.dart';

// Resident
import 'package:marianela_web/screens/resident/invites.dart';
import 'package:marianela_web/screens/resident/ticket_form_screen.dart';
import 'package:marianela_web/screens/resident/payment_screen.dart';

/// Barra inferior dinámica según el rol del usuario.
/// Roles soportados: admin | guard | resident
class HomeBottomNav extends StatelessWidget {
  final String role;
  final int currentIndex;
  final Future<void> Function() onLogout;

  const HomeBottomNav({
    super.key,
    required this.role,
    this.currentIndex = 0,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex.clamp(0, 2),
        onTap: (i) async {
          if (i == 3) {
            await onLogout();
            return;
          }

          switch (role) {
            case 'admin':
              _handleAdminNav(context, i);
              break;
            case 'guard':
              _handleGuardNav(context, i);
              break;
            case 'resident':
              _handleResidentNav(context, i);
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rol no reconocido")),
              );
          }
        },
        items: _getNavItems(role),
      ),
    );
  }

  /// 🔹 Íconos y etiquetas dinámicas según el rol
  List<BottomNavigationBarItem> _getNavItems(String role) {
    switch (role) {
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Incidencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ];

      case 'guard':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Visitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'Incidencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Bitácora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ];

      case 'resident':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            activeIcon: Icon(Icons.person_add_alt_1),
            label: 'Visitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            activeIcon: Icon(Icons.error),
            label: 'Incidencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Pago',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ];

      default:
        return const [];
    }
  }

  // =============================
  // 🔹 Navegación para ADMIN
  // =============================
  void _handleAdminNav(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const UsersListScreen()));
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TicketsListScreen()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaymentsReportScreen()));
        break;
    }
  }

  // =============================
  // 🔹 Navegación para GUARD
  // =============================
  void _handleGuardNav(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CheckinInvitesScreen()));
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TicketFormScreenGuard()),
        );
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ListInvitesScreen()));
        break;
    }
  }

  // =============================
  // 🔹 Navegación para RESIDENT
  // =============================
  void _handleResidentNav(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const InviteFormScreen()));
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TicketFormScreen()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaymentScreen()));
        break;
    }
  }
}
