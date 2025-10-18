import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/resident/ticket_comment.dart';

class TicketDetailAdminScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailAdminScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailAdminScreen> createState() =>
      _TicketDetailAdminScreenState();
}

class _TicketDetailAdminScreenState extends State<TicketDetailAdminScreen> {
  Map<String, dynamic>? ticket;
  bool isLoading = true;
  bool isClosing = false;
  bool isProcessing = false;

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
      setState(() => isLoading = false);
    }
  }

  // Cerrar ticket
  Future<void> _closeTicket() async {
    final ctrl = TextEditingController(text: 'Problema solucionado');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar cierre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Este ticket pasará a estado "cerrado". Añade una nota si deseas:',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Comentario de cierre',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cerrar ticket'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => isClosing = true);

    final res = await ApiClient.post(
      '/tickets/${widget.ticketId}/status',
      body: {'_method': 'PUT', 'status': 'cerrado', 'body': ctrl.text.trim()},
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket cerrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _fetchTicket(); // refrescar en la misma vista
    } else {
      if (!mounted) {
        return; // evita usar context si el widget ya no está montado
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar ticket (${res.statusCode})'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isClosing = false);
  }

  // Marcar como "en proceso"
  Future<void> _markInProcess() async {
    final ctrl = TextEditingController(text: 'Ticket en proceso');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marcar en proceso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Este ticket pasará a estado "en proceso". Añade una nota si deseas:',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Comentario opcional',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('Marcar en proceso'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => isProcessing = true);

    final res = await ApiClient.post(
      '/tickets/${widget.ticketId}/status',
      body: {
        '_method': 'PUT',
        'status': 'en_proceso',
        'body': ctrl.text.trim(),
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket marcado como "en proceso"'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
      await _fetchTicket(); // ✅ refresca en pantalla
    } else {
      if (!mounted) {
        return; // evita usar context si el widget ya no está montado
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar ticket (${res.statusCode})'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isProcessing = false);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
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
    final comments = (ticket?['comments'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del ticket'),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // devuelve true
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
                ? const Center(child: Text('No se pudo cargar el ticket'))
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
                        Text('Categoría: ${ticket!['category']}'),
                        const SizedBox(height: 8),
                        Text('Descripción: ${ticket!['description']}'),
                        const SizedBox(height: 8),
                        Text('Estado: ${ticket!['status']}'),
                        const SizedBox(height: 8),
                        Text(
                          'Creado: ${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(ticket!['created_at']))}',
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

                        const Text(
                          'Comentarios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (comments.isEmpty)
                          const Text('No hay comentarios aún'),
                        ...comments.map((c) {
                          final createdAt = DateFormat(
                            'yyyy-MM-dd HH:mm',
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
                                'Autor: ${c['author']['name']} • $createdAt',
                              ),
                              trailing: isResolution
                                  ? const Chip(
                                      label: Text(
                                        'RESOLUCIÓN',
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
                        }),

                        const SizedBox(height: 20),

                        // 🟣 Agregar comentario
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
                            if (result == true) _fetchTicket();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A6CF7),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Agregar comentario',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔵 Marcar en proceso
                        ElevatedButton.icon(
                          onPressed:
                              (ticket!['status']?.toString().toLowerCase() ==
                                      'cerrado' ||
                                  isProcessing)
                              ? null
                              : _markInProcess,
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                          ),
                          label: isProcessing
                              ? const Text('Actualizando...')
                              : const Text(
                                  'Marcar En Proceso',
                                  style: TextStyle(color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔴 Cerrar ticket
                        ElevatedButton.icon(
                          onPressed:
                              (ticket!['status']?.toString().toLowerCase() ==
                                      'cerrado' ||
                                  isClosing)
                              ? null
                              : _closeTicket,
                          icon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          label: isClosing
                              ? const Text('Cerrando...')
                              : const Text(
                                  'Cerrar Ticket',
                                  style: TextStyle(color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
