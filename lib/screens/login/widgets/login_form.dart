import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import 'gradient_button.dart';
import 'package:marianela_web/screens/home/support_required.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ok = await AuthService.login(
      _usuarioCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usuarioCtrl,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              hintText: 'Correo electrónico',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingrese su usuario' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            onFieldSubmitted: (_) => _submit(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingrese su contraseña' : null,
          ),
          const SizedBox(height: 18),

          // Botón con degradé estilo UI de referencia
          GradientButton(
            text: 'Ingresar',
            loading: _isLoading,
            onPressed: _submit,
          ),

          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportRequiredScreen(),
                  ),
                );
              },

              // Color del texto (y estados) del TextButton
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7A6CF7),
              ),
              child: const Text(
                '¿Olvidaste tu contraseña?\n¿Requires acceso?',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
