// lib/screens/resident/payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/login/widgets/gradient_button.dart';

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

  void _clearForm() {
    _periodCtrl.text = DateFormat('yyyy-MM').format(DateTime.now());
    _amountCtrl.clear();
    _referenceCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _method = null;
    });
    _formKey.currentState?.reset();
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
        "house_id": user['house_id'],
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
        _clearForm(); // mantener consistencia con ticket_form_screen
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
            const WaveHeader(height: 180),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildForm(context, dateLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, String dateLabel) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Reporte de Pago",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF7A6CF7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Fecha de pago (mini-card como invites)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text("Fecha de pago: $dateLabel")),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text("Seleccionar"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Período (YYYY-MM)
              TextFormField(
                controller: _periodCtrl,
                decoration: const InputDecoration(
                  labelText: 'Período (YYYY-MM)',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Indica el período';
                  final ok = RegExp(r'^\d{4}-\d{2}$').hasMatch(v.trim());
                  return ok ? null : 'Formato inválido (YYYY-MM)';
                },
              ),
              const SizedBox(height: 16),

              // Monto
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto (₡)',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Indica el monto';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Método (usar initialValue)
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(
                  labelText: 'Método',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(
                    value: 'transferencia',
                    child: Text('Transferencia'),
                  ),
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                ],
                onChanged: (v) => setState(() => _method = v),
                validator: (v) => v == null ? 'Selecciona un método' : null,
              ),
              const SizedBox(height: 16),

              // Referencia
              TextFormField(
                controller: _referenceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Referencia',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'La referencia es requerida'
                    : null,
              ),
              const SizedBox(height: 16),

              // Nota (opcional)
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  prefixIcon: Icon(Icons.sticky_note_2_outlined),
                ),
              ),
              const SizedBox(height: 30),

              // Botón consistente
              GradientButton(
                text: "Enviar reporte",
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
