import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/resident/ticket_comment.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Map<String, dynamic>? ticket;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTicket();
  }

  Future<void> _fetchTicket() async {
    final res = await ApiClient.get('/tickets/${widget.ticketId}');
    if (res.statusCode == 200) {
      setState(() {
        ticket = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del ticket"),
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

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ticket == null
                ? const Center(child: Text("No se pudo cargar el ticket"))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Text(
                          ticket!['title'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("Categoría: ${ticket!['category']}"),
                        const SizedBox(height: 8),
                        Text("Descripción: ${ticket!['description']}"),
                        const SizedBox(height: 8),
                        Text("Estado: ${ticket!['status']}"),
                        const SizedBox(height: 8),
                        Text(
                          "Creado: ${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(ticket!['created_at']))}",
                        ),
                        const SizedBox(height: 16),
                        Chip(
                          label: Text(
                            (ticket!['status'] ?? 'desconocido')
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _statusColor(
                            ticket!['status'] ?? '',
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 🔹 Sección de comentarios
                        const Text(
                          "Comentarios",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if ((ticket!['comments'] as List).isEmpty)
                          const Text("No hay comentarios aún"),
                        ...((ticket!['comments'] as List).map((c) {
                          final createdAt = DateFormat(
                            "yyyy-MM-dd HH:mm",
                          ).format(DateTime.parse(c['created_at']));
                          final isResolution = (c['is_resolution'] ?? 0) == 1;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Icon(
                                isResolution
                                    ? Icons.check_circle
                                    : Icons.comment,
                                color: isResolution
                                    ? Colors.green
                                    : const Color(0xFF7A6CF7),
                              ),
                              title: Text(c['body'] ?? ''),
                              subtitle: Text(
                                "Autor: ${c['author']['name']} • $createdAt",
                              ),
                              trailing: isResolution
                                  ? const Chip(
                                      label: Text(
                                        "RESOLUCIÓN",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                    )
                                  : null,
                            ),
                          );
                        }).toList()),

                        const SizedBox(height: 20),

                        // 🔹 Botón de agregar comentario
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketCommentScreen(
                                  ticketId: widget.ticketId,
                                ),
                              ),
                            );

                            if (result == true) {
                              _fetchTicket(); // 🔄 recarga comentarios
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A6CF7),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Agregar comentario",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
