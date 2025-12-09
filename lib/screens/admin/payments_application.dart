import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';

class PaymentsApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const PaymentsApplicationScreen({super.key, required this.report});

  @override
  State<PaymentsApplicationScreen> createState() =>
      _PaymentsApplicationScreenState();
}

class _PaymentsApplicationScreenState extends State<PaymentsApplicationScreen> {
  bool _isLoading = false;
  bool _isRejecting = false; // Estado para carga del rechazo

  // 🟢 Lógica de APLICAR (Aprobar)
  Future<void> _applyPayment() async {
    setState(() => _isLoading = true);
    try {
      final body = {
        'house_id': widget.report['house_id'],
        'period': widget.report['period'],
        'amount': widget.report['amount'],
        'method': widget.report['method'] ?? 'transferencia',
        'reference': widget.report['reference'] ?? '',
        'note': 'Pago aplicado desde validación admin',
      };

      final res = await ApiClient.post('/payments', body: body);

      if (!mounted) return;

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago aplicado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aplicar pago: ${res.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔴 Lógica de RECHAZAR
  Future<void> _rejectPayment(String reason) async {
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes indicar un motivo")));
      return;
    }

    setState(() => _isRejecting = true);
    try {
      final reportId = widget.report['id'];
      // Endpoint definido en tu api.php y PaymentReportController
      final res = await ApiClient.post(
        '/payment-reports/$reportId/reject',
        body: {'reason': reason},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El pago ha sido rechazado.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Regresamos true para recargar lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar: ${res.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isRejecting = false);
    }
  }

  // Cuadro de diálogo para pedir el motivo
  void _showRejectDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rechazar pago"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Indique el motivo por el cual rechaza este comprobante:",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Ej: Monto incompleto, captura borrosa...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx); // Cerrar el diálogo
              _rejectPayment(reasonCtrl.text.trim()); // Ejecutar rechazo
            },
            child: const Text(
              "Confirmar Rechazo",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final dateFmt = DateFormat('yyyy-MM-dd');
    final dateStr = report['date'] ?? '';
    final parsedDate = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
    final formattedDate = parsedDate != null ? dateFmt.format(parsedDate) : '—';

    // Bloqueo general si algo está cargando
    final busy = _isLoading || _isRejecting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Pago'),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7A6CF7), Color(0xFF9B59F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Ajustar al contenido
              children: [
                Text(
                  'Casa ${report['house_code'] ?? '—'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6CF7),
                  ),
                ),
                const SizedBox(height: 8),
                _kv('Período', report['period'] ?? '—'),
                _kv('Fecha', formattedDate),
                _kv('Monto', '₡${report['amount']}'),
                _kv('Método', report['method'] ?? '—'),
                _kv('Referencia', report['reference'] ?? '—'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 20),

                // 🔹 ZONA DE BOTONES
                Row(
                  children: [
                    // Botón Rechazar
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : _showRejectDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: _isRejecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.cancel),
                        label: const Text("Rechazar"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Botón Aplicar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: busy ? null : _applyPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A6CF7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isLoading ? "Aplicando..." : "Aplicar Pago",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$k:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
