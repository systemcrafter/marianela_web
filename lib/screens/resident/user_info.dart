import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/services/auth_service.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirm = false;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // ✅ carga la información actualizada desde el backend
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Carga la info actualizada del usuario desde /me
  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    // 🔹 Limpia user local antes de volver a cargar
    user = null;
    await Future.delayed(const Duration(milliseconds: 100));

    final success = await AuthService.me(); // refresca desde API
    if (success) {
      setState(() {
        user = AuthService.user;
      });
    } else {
      setState(() {
        user = null;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.put(
        '/users/password',
        body: {
          'password': _passwordCtrl.text.trim(),
          'password_confirmation': _confirmCtrl.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contraseña actualizada con éxito")),
        );
        _passwordCtrl.clear();
        _confirmCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user?['name'] ?? 'Usuario';
    // final house = user?['house']?['code'] ?? 'Sin casa asignada';
    final house = user?['house_id'] != null
        ? 'Casa ${user!['house_id']}'
        : 'Sin casa asignada';
    final email = user?['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Información del usuario"),
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
                  const WaveHeader(height: 120),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Datos del usuario",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF7A6CF7),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(name),
                                subtitle: const Text("Nombre"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.home_outlined),
                                title: Text(house),
                                subtitle: const Text("Casa asignada"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: Text(email),
                                subtitle: const Text("Correo electrónico"),
                              ),
                              const Divider(height: 40),
                              Text(
                                "Cambiar contraseña",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF7A6CF7),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _passwordCtrl,
                                      obscureText: !_showPassword,
                                      decoration: InputDecoration(
                                        labelText: "Nueva contraseña",
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                          onPressed: () => setState(
                                            () =>
                                                _showPassword = !_showPassword,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? "Ingresa una nueva contraseña"
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmCtrl,
                                      obscureText: !_showConfirm,
                                      decoration: InputDecoration(
                                        labelText: "Confirmar contraseña",
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showConfirm
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                          onPressed: () => setState(
                                            () => _showConfirm = !_showConfirm,
                                          ),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return "Confirma la contraseña";
                                        }
                                        if (v != _passwordCtrl.text) {
                                          return "Las contraseñas no coinciden";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : _changePassword,
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
                                        "Actualizar contraseña",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF7A6CF7,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          48,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
            ),
    );
  }
}
