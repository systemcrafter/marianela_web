import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class PeriodOpenScreen extends StatefulWidget {
  const PeriodOpenScreen({super.key});

  @override
  State<PeriodOpenScreen> createState() => _PeriodOpenScreenState();
}

class _PeriodOpenScreenState extends State<PeriodOpenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _periodCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '25000');
  bool _isLoading = false;

  @override
  void dispose() {
    _periodCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPeriod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.post(
        '/periods/open',
        body: {
          'period': _periodCtrl.text.trim(),
          'charge_amount': _amountCtrl.text.trim(),
        },
      );

      if (res.statusCode == 201) {
        final message =
            'Periodo ${_periodCtrl.text.trim()} abierto exitosamente';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error (${res.statusCode}): ${res.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abrir nuevo periodo"),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const WaveHeader(height: 180),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Abrir periodo",
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF7A6CF7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _periodCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Periodo (YYYY-MM)",
                                    prefixIcon: Icon(
                                      Icons.calendar_month_outlined,
                                    ),
                                  ),
                                  validator: (value) {
                                    final regex = RegExp(r'^\d{4}-\d{2}$');
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el periodo';
                                    }
                                    if (!regex.hasMatch(value)) {
                                      return 'Formato inválido. Usa YYYY-MM';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _amountCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Monto por casa (CRC)",
                                    prefixIcon: Icon(Icons.monetization_on),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el monto de cobro';
                                    }
                                    final number = double.tryParse(value);
                                    if (number == null) {
                                      return 'Debe ser un número válido';
                                    }
                                    if (number <= 0) {
                                      return 'El monto debe ser mayor que 0';
                                    }
                                    if (number > 99999) {
                                      return 'El monto no puede superar 99,999 CRC';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _openPeriod(),
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                          color: Colors.white,
                                        ),
                                  label: const Text(
                                    "Abrir periodo",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7A6CF7),
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
