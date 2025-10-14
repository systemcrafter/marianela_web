import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/admin/payments_application.dart';

class PaymentsReportScreen extends StatefulWidget {
  const PaymentsReportScreen({super.key});

  @override
  State<PaymentsReportScreen> createState() => _PaymentsReportScreenState();
}

class _PaymentsReportScreenState extends State<PaymentsReportScreen> {
  late Future<List<Map<String, dynamic>>> _futureReports;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _futureReports = _fetchReports();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReports = _fetchReports();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    final res = await ApiClient.get('/payment-reports?page=1');
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (j['data'] as List).cast<Map<String, dynamic>>();
      return data;
    } else {
      throw Exception("Error al cargar reportes (${res.statusCode})");
    }
  }

  void _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom
        ? _fromDate ?? DateTime.now()
        : _toDate ?? DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() {
        if (isFrom) {
          _fromDate = newDate;
        } else {
          _toDate = newDate;
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

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes de pagos"),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _fromDate == null ? "Desde" : dateFmt.format(_fromDate!),
                    ),
                    onPressed: () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _toDate == null ? "Hasta" : dateFmt.format(_toDate!),
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
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureReports,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final reports = (snapshot.data ?? []).where((r) {
                    final dateStr = (r['date'] ?? '').toString();
                    final parsedDate = DateTime.tryParse(dateStr);
                    return _inRange(parsedDate);
                  }).toList();

                  if (reports.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 40),
                        Center(
                          child: Text(
                            'No hay reportes de pago en el rango seleccionado.',
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: reports.length,
                    itemBuilder: (context, i) {
                      final r = reports[i];

                      final dateStr = (r['date'] ?? '').toString();
                      final parsedDate = dateStr.isNotEmpty
                          ? DateTime.tryParse(dateStr)
                          : null;
                      final formattedDate = parsedDate != null
                          ? dateFmt.format(parsedDate)
                          : 'Sin fecha';

                      return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentsApplicationScreen(report: r),
                            ),
                          );
                          if (result != null && mounted) {
                            await _refresh();
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r['house_code'] ?? '—',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        r['status'] ?? '—',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: _statusColor(
                                        r['status'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _kv('Período', r['period'] ?? '—'),
                                _kv('Fecha', formattedDate),
                                _kv('Monto', '₡${r['amount']}'),
                                _kv('Método', r['method'] ?? '—'),
                                _kv('Referencia', r['reference'] ?? '—'),
                                _kv('Residente', r['resident_name'] ?? '—'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
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

  Color _statusColor(String? status) {
    switch (status) {
      case 'validado':
        return Colors.green;
      case 'aplicado':
        return Colors.blue;
      case 'reportado':
        return Colors.orange;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
