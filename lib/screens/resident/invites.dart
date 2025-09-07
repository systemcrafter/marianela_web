import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/login/widgets/gradient_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _visitorCtrl.dispose();
    _identificationCtrl.dispose();
    super.dispose();
  }

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
        final invite = jsonDecode(res.body);
        final shortCode = invite["short_code"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invitación registrada con éxito")),
        );

        _formKey.currentState!.reset();
        setState(() {
          _validFrom = null;
          _validUntil = null;
        });

        // 👉 Diferente comportamiento en móvil vs web
        if (!kIsWeb) {
          // 📱 Android/iOS → menú nativo de compartir
          Share.share(
            "Has autorizado una visita a Residencial Marianela.\n"
            "Código: $shortCode\n"
            "Válido desde ${invite["valid_from"]} hasta ${invite["valid_until"]}",
          );
        } else {
          // 💻 Web → fallback: mostrar dialog con botón copiar
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Invitación creada"),
              content: SelectableText("Código: $shortCode"),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shortCode));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Código copiado al portapapeles"),
                      ),
                    );
                  },
                  child: const Text("Copiar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ],
            ),
          );
        }
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
      appBar: AppBar(
        title: const Text("Autorizar Visitas"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WaveHeader(height: 220), // Ola decorativa
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
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
                "Registro de Visita",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF7A6CF7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _visitorCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre del visitante",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa el nombre del visitante" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identificationCtrl,
                decoration: const InputDecoration(
                  labelText: "Identificación",
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa la identificación" : null,
              ),
              const SizedBox(height: 20),

              // 📅 Card con fechas
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 12),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              GradientButton(
                text: "Registrar",
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
