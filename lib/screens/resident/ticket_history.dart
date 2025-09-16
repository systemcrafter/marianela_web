import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/resident/ticket_detail.dart';

class TicketsHistoryScreen extends StatefulWidget {
  const TicketsHistoryScreen({super.key});

  @override
  State<TicketsHistoryScreen> createState() => _TicketsHistoryScreenState();
}

class _TicketsHistoryScreenState extends State<TicketsHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final res = await ApiClient.get('/tickets/my');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Error al cargar tickets (${res.statusCode})");
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abierto':
        return Colors.orange;
      case 'cerrado':
        return Colors.green;
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

  bool _isWithinRange(Map<String, dynamic> ticket) {
    try {
      final createdAt = DateTime.parse(ticket['created_at']);
      if (_fromDate != null && createdAt.isBefore(_fromDate!)) return false;
      if (_toDate != null && createdAt.isAfter(_toDate!)) return false;
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de tickets"),
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
          const WaveHeader(height: 120),

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

          // 🔹 Lista de tickets
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchTickets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    var tickets = snapshot.data ?? [];
                    tickets = tickets.where(_isWithinRange).toList();

                    if (tickets.isEmpty) {
                      return const Center(
                        child: Text("No hay tickets en este rango"),
                      );
                    }

                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final t = tickets[index];
                        final status = t['status'] ?? 'desconocido';
                        final createdAt = DateFormat(
                          "yyyy-MM-dd HH:mm",
                        ).format(DateTime.parse(t['created_at']));

                        final lastComment = (t['comments'] as List).isNotEmpty
                            ? t['comments'].last['body']
                            : "Sin comentarios";

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
                            title: Text(t['title'] ?? 'Sin título'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Categoría: ${t['category']}"),
                                Text("Descripción: ${t['description']}"),
                                Text("Creado: $createdAt"),
                                Text("Último comentario: $lastComment"),
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

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TicketDetailScreen(ticketId: t['id']),
                                ),
                              );
                            },
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
