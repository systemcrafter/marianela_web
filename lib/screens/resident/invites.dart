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
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class InviteFormScreen extends StatefulWidget {
  const InviteFormScreen({super.key});

  @override
  State<InviteFormScreen> createState() => _InviteFormScreenState();
}

class _InviteFormScreenState extends State<InviteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _visitorCtrl = TextEditingController();
  final _identificationCtrl = TextEditingController();
  DateTime? _validFrom = DateTime.now();
  DateTime? _validUntil = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _visitorCtrl.dispose();
    _identificationCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Nueva función para limpiar campos
  void _clearForm() {
    _visitorCtrl.clear();
    _identificationCtrl.clear();
    setState(() {
      _validFrom = DateTime.now();
      _validUntil = DateTime.now();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _validFrom ?? now : _validUntil ?? now,
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

        /// ✅ limpiamos los campos
        _clearForm();

        if (!kIsWeb) {
          // 📱 Android/iOS → menú nativo de compartir
          await Share.share(
            "Has autorizado una visita a Residencial Marianela.\n"
            "Código: $shortCode\n"
            "Válido desde ${invite["valid_from"]} hasta ${invite["valid_until"]}",
            subject: "Nueva invitación",
          );
        } else {
          // 💻 Web → mostrar dialog con código y QR
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Invitación creada"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText("Código: $shortCode"),
                  const SizedBox(height: 16),
                  if (invite["qr_code"] != null)
                    Image.memory(
                      base64Decode(invite["qr_code"].split(",").last),
                      width: 160,
                      height: 160,
                    ),
                ],
              ),
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
                  child: const Text("Copiar código"),
                ),
                TextButton(
                  onPressed: () {
                    final qrBytes = base64Decode(
                      invite["qr_code"].split(",").last,
                    );

                    final blob = html.Blob([qrBytes]);
                    final url = html.Url.createObjectUrlFromBlob(blob);

                    html.AnchorElement(href: url)
                      ..setAttribute("download", "qr_code.png")
                      ..click();

                    html.Url.revokeObjectUrl(url);
                  },
                  child: const Text("Descargar QR"),
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
        foregroundColor: Colors.white, // 🔹 letras blancas
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
                              "Desde: ${DateFormat("yyyy-MM-dd").format(_validFrom!)}",
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
                              "Hasta: ${DateFormat("yyyy-MM-dd").format(_validUntil!)}",
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
