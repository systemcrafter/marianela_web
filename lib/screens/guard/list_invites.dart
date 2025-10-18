import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class ListInvitesScreen extends StatefulWidget {
  const ListInvitesScreen({super.key});

  @override
  State<ListInvitesScreen> createState() => _ListInvitesScreenState();
}

class _ListInvitesScreenState extends State<ListInvitesScreen> {
  late Future<_TodayResult> _future;
  static const String _tz = 'America/Costa_Rica';

  @override
  void initState() {
    super.initState();
    _future = _fetchToday();
  }

  Future<_TodayResult> _fetchToday() async {
    final res = await ApiClient.get("/invites/checkins/today?tz=$_tz");
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return _TodayResult.fromJson(json);
    }
    throw Exception("Error ${res.statusCode}: ${res.body}");
  }

  Future<void> _refresh() async {
    setState(() => _future = _fetchToday());
  }

  String _fmtLocal(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd/MM HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildHeader(_TodayResult data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WaveHeader(height: 180),
        Transform.translate(
          offset: const Offset(0, -24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DefaultTextStyle(
                  style: const TextStyle(fontSize: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ingresos de visitas (hoy)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Fecha: ${data.date}  •  TZ: ${data.timezone}"),
                      Text(
                        "Ventana UTC: ${data.windowFrom} → ${data.windowTo}",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.how_to_reg),
                          const SizedBox(width: 8),
                          Text(
                            "Total registrados: ${data.total}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(Map<String, dynamic> it) {
    final visitor = (it['visitor_name'] ?? '').toString();
    final idCard = (it['identification'] ?? '').toString();
    final house = (it['house_code'] ?? '').toString();
    final resident = (it['resident_name'] ?? '').toString();
    final when = (it['checked_in_at'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.check)),
        title: Text(
          visitor.isEmpty ? '—' : visitor,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (idCard.isNotEmpty) Text("Identificación: $idCard"),
            if (house.isNotEmpty) Text("Casa: $house"),
            if (resident.isNotEmpty) Text("Residente: $resident"),
            if (when.isNotEmpty) Text("Ingreso: ${_fmtLocal(when)}"),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingresos del día"),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: "Recargar",
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
      body: FutureBuilder<_TodayResult>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "No se pudo cargar la lista.\n${snap.error}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reintentar"),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: (data.items.isEmpty ? 1 : data.items.length) + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader(data);
                if (data.items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.inbox_outlined),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text("No hay ingresos registrados hoy."),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final it = data.items[index - 1];
                return _buildItem(it);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TodayResult {
  final String date;
  final String timezone;
  final String windowFrom;
  final String windowTo;
  final int total;
  final List<Map<String, dynamic>> items;

  _TodayResult({
    required this.date,
    required this.timezone,
    required this.windowFrom,
    required this.windowTo,
    required this.total,
    required this.items,
  });

  factory _TodayResult.fromJson(Map<String, dynamic> json) {
    final win = (json['window_utc'] ?? {}) as Map<String, dynamic>;
    final rawItems = (json['items'] as List<dynamic>? ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    return _TodayResult(
      date: (json['date'] ?? '').toString(),
      timezone: (json['timezone'] ?? '').toString(),
      windowFrom: (win['from'] ?? '').toString(),
      windowTo: (win['to'] ?? '').toString(),
      total: (json['total'] ?? 0) as int,
      items: rawItems,
    );
  }
}
