import 'package:flutter/material.dart';
import 'package:marianela_web/core/services/api_client.dart';
import 'package:marianela_web/core/widgets/wave_header.dart';
import 'package:marianela_web/screens/login/widgets/gradient_button.dart';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user; // null => crear

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _role = 'resident';
  String? _selectedHouseId;
  bool _saving = false;
  bool _showPassword = false; // 👁️ control de visibilidad

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _nameCtrl.text = widget.user!['name'] ?? '';
      _emailCtrl.text = widget.user!['email'] ?? '';
      _role = widget.user!['role'] ?? 'resident';
      _selectedHouseId = widget.user!['house_id']?.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final body = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _role,
        'house_id': (_role == 'resident' && _selectedHouseId != null)
            ? int.tryParse(_selectedHouseId!)
            : null,
      };

      if (isEdit) {
        if (_passwordCtrl.text.trim().isNotEmpty) {
          body['password'] = _passwordCtrl.text.trim();
          body['password_confirmation'] = _confirmCtrl.text.trim(); // ✅ nuevo
        }
        final id = widget.user!['id'];
        final res = await ApiClient.put('/users/$id', body: body);
        if (res.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuario actualizado')),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showErr(res.statusCode, res.body);
        }
      } else {
        if (_passwordCtrl.text.trim().isEmpty) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La contraseña es obligatoria'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        body['password'] = _passwordCtrl.text.trim();
        body['password_confirmation'] = _confirmCtrl.text.trim(); // ✅ nuevo

        final res = await ApiClient.post('/users', body: body);
        if (res.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Usuario creado')));
            Navigator.pop(context, true);
          }
        } else {
          _showErr(res.statusCode, res.body);
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showErr(int code, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error ($code): $body'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houses = List<DropdownMenuItem<String>>.generate(103, (i) {
      final n = i + 1;
      final display = (n == 103) ? 'COMMON_HOUSE_ID' : 'Casa $n';
      return DropdownMenuItem<String>(value: '$n', child: Text(display));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Editar usuario" : "Nuevo usuario"),
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
            const WaveHeader(height: 110),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildForm(context, houses),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<DropdownMenuItem<String>> houses,
  ) {
    final houseDisabled = _role != 'resident';

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
                isEdit ? "Editar Usuario" : "Registro de Usuario",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF7A6CF7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa el nombre del usuario" : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Ingresa el correo electrónico" : null,
              ),
              const SizedBox(height: 16),

              // Rol
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'resident', child: Text('Residente')),
                  DropdownMenuItem(value: 'guard', child: Text('Guardia')),
                ],
                onChanged: (v) => setState(() {
                  _role = v ?? 'resident';
                  if (_role != 'resident') _selectedHouseId = null;
                }),
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Casa
              DropdownButtonFormField<String>(
                initialValue: _selectedHouseId,
                items: houses,
                onChanged: houseDisabled
                    ? null
                    : (v) => setState(() => _selectedHouseId = v),
                decoration: const InputDecoration(
                  labelText: 'Casa asignada',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (v) {
                  if (houseDisabled) return null;
                  return (v == null || v.isEmpty)
                      ? "Selecciona una casa"
                      : null;
                },
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Contraseña (opcional)' : 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmCtrl,
                obscureText: !_showPassword,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) {
                  if (_passwordCtrl.text.isNotEmpty &&
                      v != _passwordCtrl.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              GradientButton(
                text: isEdit ? "Guardar cambios" : "Crear usuario",
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
