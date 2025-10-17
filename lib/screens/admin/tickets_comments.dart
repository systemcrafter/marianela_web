import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class TicketsCommentsScreen extends StatefulWidget {
  final int ticketId;
  const TicketsCommentsScreen({super.key, required this.ticketId});

  @override
  State<TicketsCommentsScreen> createState() => _TicketsCommentsScreenState();
}

class _TicketsCommentsScreenState extends State<TicketsCommentsScreen> {
  final _commentCtrl = TextEditingController();
  late Future<List<Map<String, dynamic>>> _futureComments;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _futureComments = _fetchComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    final res = await ApiClient.get('/tickets/${widget.ticketId}/comments');
    if (res.statusCode != 200) {
      throw Exception('Error al cargar comentarios (${res.statusCode})');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _sendComment() async {
    final txt = _commentCtrl.text.trim();
    if (txt.isEmpty || _isSending) return;

    final user = AuthService.user;
    if (user == null || user['id'] == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no autenticado')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final res = await ApiClient.post(
        '/tickets/${widget.ticketId}/comments',
        body: {'author_id': user['id'], 'body': txt, 'is_resolution': false},
      ); // <- body como named argument (firma de ApiClient.post) :contentReference[oaicite:4]{index=4}

      if (!mounted) return;

      if (res.statusCode == 201 || res.statusCode == 200) {
        _commentCtrl.clear();
        setState(() {
          _futureComments = _fetchComments(); // recargar lista
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar comentario (${res.statusCode})'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar comentario: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _item(Map<String, dynamic> c) {
    final author = c['author'] ?? {};
    final name = (author['name'] ?? 'Usuario').toString();
    final body = (c['body'] ?? '').toString();
    final createdAt = c['created_at']?.toString();
    final dateStr = (createdAt != null && createdAt.isNotEmpty)
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(createdAt))
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(body),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios del ticket'),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: const WaveHeader(),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureComments,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('No hay comentarios.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _item(items[i]),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendComment,
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
