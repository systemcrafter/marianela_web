import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  // Variables para Reporte de Tickets (Rango)
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  // Variables para Reporte de Cuentas (Periodo)
  DateTime _selectedPeriod = DateTime.now();

  bool _isLoading = false;

  // Selector de fechas (Desde/Hasta)
  Future<void> _pickDateRange(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // Selector de Periodo (Visualmente elegimos un mes)
  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPeriod,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: "SELECCIONA EL MES DEL PERIODO",
    );
    if (picked != null) {
      setState(() => _selectedPeriod = picked);
    }
  }

  Future<void> _downloadReport(String type) async {
    setState(() => _isLoading = true);

    String url = "";
    String fileName = "";

    // Lógica condicional según el botón presionado
    if (type == 'accounts') {
      final periodStr = DateFormat('yyyy-MM').format(_selectedPeriod);
      url = '/reports/accounts?period=$periodStr';
      fileName = 'reporte_cuentas_$periodStr.csv';
    } else {
      final f = DateFormat('yyyy-MM-dd');
      url =
          '/reports/tickets?from=${f.format(_fromDate)}&to=${f.format(_toDate)}';
      fileName = 'reporte_incidencias.csv';
    }

    try {
      // 1. Petición al Backend (ya incluye el token de Admin)
      final res = await ApiClient.get(url);

      if (res.statusCode == 200) {
        // 2. Truco para descargar Blob en Web
        final blob = html.Blob([res.bodyBytes], 'text/csv');
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        // final anchor = html.AnchorElement(href: blobUrl)
        //   ..setAttribute("download", fileName)
        //   ..click();

        // Usamos el anchor directamente sin asignarlo a variable para evitar el warning
        html.AnchorElement(href: blobUrl)
          ..setAttribute("download", fileName)
          ..click();

        html.Url.revokeObjectUrl(blobUrl);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Descarga completada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fDate = DateFormat('dd/MM/yyyy');
    final fPeriod = DateFormat('yyyy-MM'); // Formato visual del periodo

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes y Auditoría"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
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
      body: Column(
        children: [
          const WaveHeader(height: 140),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ), // Evita que se estire demasiado en PC
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // TARJETA 1: REPORTE DE CUENTAS
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Color(0xFF7A6CF7),
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Estado de Cuentas",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Genera un reporte de pagos y deudas filtrado por el periodo contable.",
                            ),
                            const Divider(height: 24),

                            const Text(
                              "Selecciona el Periodo (Mes):",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month),
                              label: Text(
                                "Periodo: ${fPeriod.format(_selectedPeriod)}",
                              ),
                              onPressed: _pickPeriod,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7A6CF7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.download),
                                label: const Text("Descargar CSV"),
                                onPressed: _isLoading
                                    ? null
                                    : () => _downloadReport('accounts'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TARJETA 2: REPORTE DE INCIDENCIAS
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.support_agent,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Historial de Incidencias",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Descarga el detalle de tickets, estados y comentarios en un rango de fechas.",
                            ),
                            const Divider(height: 24),

                            const Text(
                              "Rango de creación:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(fDate.format(_fromDate)),
                                    onPressed: () => _pickDateRange(true),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text("—"),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(fDate.format(_toDate)),
                                    onPressed: () => _pickDateRange(false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.download),
                                label: const Text("Descargar CSV"),
                                onPressed: _isLoading
                                    ? null
                                    : () => _downloadReport('tickets'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
