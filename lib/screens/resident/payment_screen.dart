import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _periodCtrl = TextEditingController(); // YYYY-MM
  final _amountCtrl = TextEditingController(); // entero
  final _referenceCtrl = TextEditingController(); // string
  final _noteCtrl = TextEditingController(); // opcional

  DateTime _selectedDate = DateTime.now();
  String? _method; // efectivo | transferencia | tarjeta
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // período por defecto: YYYY-MM actual
    _periodCtrl.text = DateFormat('yyyy-MM').format(DateTime.now());
  }

  @override
  void dispose() {
    _periodCtrl.dispose();
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.user;
    if (user == null || user['house_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario o casa no disponible')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        "house_id": user['house_id'], // tomado del usuario logueado
        "period": _periodCtrl.text.trim(), // YYYY-MM
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "amount": int.parse(_amountCtrl.text.trim()),
        "method": _method,
        "reference": _referenceCtrl.text.trim(),
        "note": _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      };

      final res = await ApiClient.post('/payment-reports', body: data);
      if (!mounted) return;

      if (res.statusCode == 201) {
        final payload = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte enviado: ${payload["message"]}')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.statusCode} - ${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      // AppBar con gradiente igual a ticket_comment.dart
      appBar: AppBar(
        title: const Text('Reportar pago'),
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            const WaveHeader(height: 180), // ola superior

            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Periodo YYYY-MM
                      TextFormField(
                        controller: _periodCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Período (YYYY-MM)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Indica el período';
                          }
                          final ok = RegExp(
                            r'^\d{4}-\d{2}$',
                          ).hasMatch(v.trim());
                          return ok ? null : 'Formato inválido (YYYY-MM)';
                        },
                      ),
                      const SizedBox(height: 12),

                      // Fecha del pago (selector)
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha del pago',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateLabel),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Monto
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto (₡)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Indica el monto';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Monto inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Método
                      DropdownButtonFormField<String>(
                        value: _method,
                        decoration: const InputDecoration(
                          labelText: 'Método',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'efectivo',
                            child: Text('Efectivo'),
                          ),
                          DropdownMenuItem(
                            value: 'transferencia',
                            child: Text('Transferencia'),
                          ),
                          DropdownMenuItem(
                            value: 'tarjeta',
                            child: Text('Tarjeta'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _method = v),
                        validator: (v) =>
                            v == null ? 'Selecciona un método' : null,
                      ),
                      const SizedBox(height: 12),

                      // Referencia
                      TextFormField(
                        controller: _referenceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Referencia',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'La referencia es requerida'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Nota (opcional)
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Nota (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A6CF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Enviar reporte',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
