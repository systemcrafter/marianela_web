import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'home_screen_admin.dart';
import 'home_screen_resident.dart';
import 'home_screen_guard.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (AuthService.role) {
      UserRole.admin => const HomeScreenAdmin(),
      UserRole.resident => const HomeScreenResident(),
      UserRole.guard => const HomeScreenGuard(),
      _ => const _UnknownRole(),
    };
  }
}

class _UnknownRole extends StatelessWidget {
  const _UnknownRole();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('No se pudo determinar tu rol')),
    );
  }
}
