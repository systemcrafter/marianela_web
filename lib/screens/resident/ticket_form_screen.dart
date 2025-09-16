import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/login/widgets/gradient_button.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _category;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Limpiar formulario después de enviar
  void _clearForm() {
    _titleCtrl.clear();
    _descriptionCtrl.clear();
    setState(() {
      _category = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService.user!;
      final data = {
        "resident_id": user["resident_id"] ?? user["id"],
        "house_id": user["house_id"],
        "category": _category,
        "title": _titleCtrl.text.trim(),
        "description": _descriptionCtrl.text.trim(),
      };

      final res = await ApiClient.post("/tickets", body: data);

      if (!mounted) return;

      if (res.statusCode == 201) {
        final ticket = jsonDecode(res.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tiquete #${ticket["id"]} creado con éxito")),
        );

        _clearForm();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abrir Tiquete"),
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
            const WaveHeader(height: 180), // Ola decorativa
            Transform.translate(
              offset: const Offset(0, -20),
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
                "Registrar Tiquete",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF7A6CF7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// Categoría
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Categoría",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                value: _category,
                items: const [
                  DropdownMenuItem(value: "limpieza", child: Text("Limpieza")),
                  DropdownMenuItem(
                    value: "seguridad",
                    child: Text("Seguridad"),
                  ),
                  DropdownMenuItem(
                    value: "zonas_verdes",
                    child: Text("Zonas verdes"),
                  ),
                  DropdownMenuItem(
                    value: "zonas_comunes",
                    child: Text("Zonas comunes"),
                  ),
                  DropdownMenuItem(value: "otro", child: Text("Otro")),
                ],
                onChanged: (value) => setState(() => _category = value),
                validator: (v) => v == null ? "Selecciona una categoría" : null,
              ),
              const SizedBox(height: 16),

              /// Título
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Título",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? "Ingresa un título" : null,
              ),
              const SizedBox(height: 16),

              /// Descripción
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? "Ingresa una descripción" : null,
              ),

              const SizedBox(height: 30),

              /// Botón registrar
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
