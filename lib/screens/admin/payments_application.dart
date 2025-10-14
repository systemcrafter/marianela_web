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

  Future<void> _applyPayment() async {
    setState(() => _isLoading = true);

    try {
      // 🔹 Armar body para el endpoint /api/payments
      final body = {
        'house_id': widget.report['house_id'],
        'period': widget
            .report['period'], // 👈 usa el string del reporte, ej: "2025-10"
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

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final dateFmt = DateFormat('yyyy-MM-dd');
    final dateStr = report['date'] ?? '';
    final parsedDate = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
    final formattedDate = parsedDate != null ? dateFmt.format(parsedDate) : '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicar pago'),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _applyPayment,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Aplicando pago...' : '¿Aplicar pago?',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A6CF7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
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
