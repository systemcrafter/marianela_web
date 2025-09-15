import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class CheckinInvitesScreen extends StatefulWidget {
  const CheckinInvitesScreen({super.key});

  @override
  State<CheckinInvitesScreen> createState() => _CheckinInvitesScreenState();
}

class _CheckinInvitesScreenState extends State<CheckinInvitesScreen> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkinInvite() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes ingresar un código")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.post(
        "/invites/checkin",
        body: {"short_code": code},
      );

      if (!mounted) return; // 👈 evitamos error de contexto

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invitación marcada como usada: ${data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        _codeCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // 👈 evitamos error de contexto
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
        title: const Text("Check-in de invitaciones"),
        backgroundColor: const Color(0xFF7A6CF7),
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const WaveHeader(height: 120), // Ola decorativa
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Verificación y registro de ingreso",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF7A6CF7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(
                          labelText: "Código de invitación",
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkinInvite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A6CF7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isLoading ? "Procesando..." : "Registrar ingreso",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
