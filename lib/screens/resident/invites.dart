import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/services/api_client.dart';

class InviteFormScreen extends StatefulWidget {
  const InviteFormScreen({super.key});

  @override
  State<InviteFormScreen> createState() => _InviteFormScreenState();
}

class _InviteFormScreenState extends State<InviteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _visitorCtrl = TextEditingController();
  final _identificationCtrl = TextEditingController();
  DateTime? _validFrom;
  DateTime? _validUntil;
  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_validFrom == null || _validUntil == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona ambas fechas')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService.user!;
      final data = {
        "resident_id": user["resident_id"] ?? user["id"],
        "house_id": user["house_id"],
        "visitor_name": _visitorCtrl.text.trim(),
        "identification": _identificationCtrl.text.trim(),
        "valid_from": DateFormat("yyyy-MM-dd").format(_validFrom!),
        "valid_until": DateFormat("yyyy-MM-dd").format(_validUntil!),
      };

      final res = await ApiClient.post("/invites", body: data);

      if (!mounted) return;

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invitación registrada con éxito")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _validFrom = null;
          _validUntil = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${res.body}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Invitación")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _visitorCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre del visitante",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa el nombre del visitante" : null,
              ),
              TextFormField(
                controller: _identificationCtrl,
                decoration: const InputDecoration(labelText: "Identificación"),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa la identificación" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _validFrom == null
                          ? "Desde: no seleccionado"
                          : "Desde: ${DateFormat("yyyy-MM-dd").format(_validFrom!)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(context, true),
                    child: const Text("Seleccionar"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _validUntil == null
                          ? "Hasta: no seleccionado"
                          : "Hasta: ${DateFormat("yyyy-MM-dd").format(_validUntil!)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(context, false),
                    child: const Text("Seleccionar"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Enviar Invitación"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
