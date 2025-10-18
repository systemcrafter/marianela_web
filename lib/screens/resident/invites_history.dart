import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // 👈 necesario para copiar
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class InvitesHistoryScreen extends StatefulWidget {
  const InvitesHistoryScreen({super.key});

  @override
  State<InvitesHistoryScreen> createState() => _InvitesHistoryScreenState();
}

class _InvitesHistoryScreenState extends State<InvitesHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<List<Map<String, dynamic>>> _fetchInvites() async {
    final res = await ApiClient.get('/invites/my');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar invitaciones (${res.statusCode})");
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'emitido':
        return const Color(0xFF7A6CF7); // morado
      case 'usado':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final now = DateTime.now();
    final initial = isFrom ? _fromDate ?? now : _toDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
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

  bool _isWithinRange(Map<String, dynamic> invite) {
    try {
      final validFrom = DateTime.parse(invite['valid_from']);
      final validUntil = DateTime.parse(invite['valid_until']);

      if (_fromDate != null && validUntil.isBefore(_fromDate!)) return false;
      if (_toDate != null && validFrom.isAfter(_toDate!)) return false;

      return true;
    } catch (_) {
      return true;
    }
  }

  void _copyShortCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Código $code copiado al portapapeles")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de invitaciones"),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7A6CF7),
                Color(0xFF9B59F6),
              ], // mismos tonos de WaveHeader
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          const WaveHeader(height: 180), // Ola decorativa
          // 🔹 Filtro de fechas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _fromDate == null
                          ? "Desde"
                          : DateFormat("yyyy-MM-dd").format(_fromDate!),
                    ),
                    onPressed: () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _toDate == null
                          ? "Hasta"
                          : DateFormat("yyyy-MM-dd").format(_toDate!),
                    ),
                    onPressed: () => _pickDate(context, false),
                  ),
                ),
                if (_fromDate != null || _toDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),

          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchInvites(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    var invites = snapshot.data ?? [];
                    invites = invites.where(_isWithinRange).toList();

                    if (invites.isEmpty) {
                      return const Center(
                        child: Text("No hay invitaciones en este rango"),
                      );
                    }

                    return ListView.builder(
                      itemCount: invites.length,
                      itemBuilder: (context, index) {
                        final invite = invites[index];
                        final status = invite['status'] ?? 'desconocido';
                        final shortCode = invite['short_code'] ?? 'N/A';

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              color: Color(0xFF7A6CF7),
                            ),
                            title: Text(
                              invite['visitor_name'] ?? 'Invitado sin nombre',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Identificación: ${invite['identification'] ?? 'N/A'}",
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      _copyShortCode(context, shortCode),
                                  child: Text(
                                    "Código: $shortCode (toca para copiar)",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Válido: ${invite['valid_from']} → ${invite['valid_until']}",
                                ),
                                const SizedBox(height: 6),
                                Chip(
                                  label: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _statusColor(status),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
