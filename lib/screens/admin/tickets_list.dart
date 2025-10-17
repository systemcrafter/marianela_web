import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/admin/tickets_detail.dart';

class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({super.key});

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  late Future<List<Map<String, dynamic>>> _futureTickets;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _statusFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _futureTickets = _fetchTickets();
  }

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final res = await ApiClient.get('/tickets');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception("Error al cargar tickets (${res.statusCode})");
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom
        ? _fromDate ?? DateTime.now()
        : _toDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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

  bool _inRange(DateTime? date) {
    if (date == null) return true;
    if (_fromDate != null && date.isBefore(_fromDate!)) return false;
    if (_toDate != null && date.isAfter(_toDate!)) return false;
    return true;
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'abierto':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickets"),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
          const WaveHeader(height: 90),
          const SizedBox(height: 8),

          // 🔹 Filtro por estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusButton('abierto', Colors.orange),
                _statusButton('en_proceso', Colors.blue),
                _statusButton('cerrado', Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Filtros por fecha
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _fromDate == null ? 'Desde' : dateFmt.format(_fromDate!),
                    ),
                    onPressed: () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _toDate == null ? 'Hasta' : dateFmt.format(_toDate!),
                    ),
                    onPressed: () => _pickDate(context, false),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Lista de tickets
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureTickets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final all = snapshot.data ?? [];
                final filtered = all.where((t) {
                  final status = (t['status'] ?? '').toString().toLowerCase();
                  final createdAt = DateTime.tryParse(
                    (t['created_at'] ?? '').toString(),
                  );
                  final statusOk =
                      _statusFilter == 'todos' || status == _statusFilter;
                  final dateOk = _inRange(createdAt);
                  return statusOk && dateOk;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No hay tickets con esos filtros"),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final t = filtered[i];
                      final created = DateTime.tryParse(
                        (t['created_at'] ?? '').toString(),
                      );
                      final createdStr = created != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(created)
                          : 'Fecha desconocida';

                      final lastComment =
                          (t['comments'] is List &&
                              (t['comments'] as List).isNotEmpty)
                          ? (t['comments'] as List).last['body']
                          : 'Sin comentarios';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.assignment,
                            color: Color(0xFF7A6CF7),
                          ),
                          title: Text(
                            (t['title'] ?? 'Sin título').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Categoría: ${t['category'] ?? 'N/D'}"),
                              Text("Descripción: ${t['description'] ?? 'N/D'}"),
                              Text("Creado: $createdStr"),
                              Text("Último comentario: $lastComment"),
                              const SizedBox(height: 6),
                              Chip(
                                label: Text(
                                  (t['status'] ?? 'N/D')
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _statusColor(
                                  (t['status'] ?? '').toString(),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            // ✅ Espera el resultado del detalle
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailAdminScreen(
                                  ticketId:
                                      int.tryParse(t['id'].toString()) ?? 0,
                                ),
                              ),
                            );

                            // ✅ Si el ticket fue cerrado, refresca la lista
                            if (result == true && mounted) {
                              setState(() {
                                _futureTickets = _fetchTickets();
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String status, Color color) {
    final active = _statusFilter == status;
    return ChoiceChip(
      label: Text(status),
      selected: active,
      selectedColor: color.withValues(alpha: 0.15),
      onSelected: (_) => setState(() => _statusFilter = status),
      labelStyle: TextStyle(
        color: active ? color : Colors.black87,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
