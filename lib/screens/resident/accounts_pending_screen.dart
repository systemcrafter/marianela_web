import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/services/auth_service.dart';

class AccountsPendingScreen extends StatelessWidget {
  const AccountsPendingScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchAccounts() async {
    // 🔹 Tomamos el house_id del usuario actual
    final houseId = AuthService.user?['house_id'];

    if (houseId == null) {
      throw Exception("No se encontró house_id en el usuario");
    }

    // 🔹 Usamos la ruta de pendientes
    final res = await ApiClient.get('/accounts/house/$houseId/pending');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar cuentas (${res.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cuentas pendientes")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final cuentas = snapshot.data ?? [];
          if (cuentas.isEmpty) {
            return const Center(child: Text("No hay cuentas pendientes"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cuentas.length,
            itemBuilder: (context, index) {
              final cuenta = cuentas[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF7A6CF7),
                  ),
                  title: Text("Periodo: ${cuenta['period']}"),
                  subtitle: Text(
                    "Monto: ₡${cuenta['charge_amount']}\nEstado: ${cuenta['status']}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 🔹 Aquí en la siguiente parte abriremos el detalle de la cuenta
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
