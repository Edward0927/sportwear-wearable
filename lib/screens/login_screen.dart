import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/api_exception.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';
import 'pairing_flow_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PairingFlowScreen()),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      
      setState(() => _error = 'No se pudo conectar con el servidor. Revisa tu conexión.\n($e)');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = WearLayout.isSmallScreen(context);

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: WearLayout.safePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: WearLayout.safeContentWidth(context)),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: small ? 8 : 24),
                Container(
                  width: small ? 36 : 52,
                  height: small ? 36 : 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bolt_rounded, color: AppColors.black, size: small ? 20 : 28),
                ),
                SizedBox(height: small ? 10 : 24),
                Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: small ? 16 : 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: small ? 4 : 6),
                Text(
                  'Inicia sesión para vincular tu banda',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gray600, fontSize: small ? 11 : 14),
                ),
                SizedBox(height: small ? 16 : 32),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: small ? 12 : 16),
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    labelStyle: TextStyle(fontSize: small ? 11 : 14),
                    errorMaxLines: 2,
                    errorStyle: TextStyle(fontSize: small ? 9 : 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return small ? 'Requerido' : 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                SizedBox(height: small ? 10 : 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: TextStyle(fontSize: small ? 12 : 16),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(fontSize: small ? 11 : 14),
                    errorMaxLines: 2,
                    errorStyle: TextStyle(fontSize: small ? 9 : 12),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return small ? 'Requerido' : 'Ingresa tu contraseña';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  SizedBox(height: small ? 8 : 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.red, fontSize: small ? 11 : 13),
                  ),
                ],
                SizedBox(height: small ? 14 : 24),
                SizedBox(
                  width: double.infinity,
                  height: small ? 38 : 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: small ? ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)) : null,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                          )
                        : Text('INICIAR SESIÓN', style: TextStyle(fontSize: small ? 9 : 14)),
                  ),
                ),
                SizedBox(height: small ? 6 : 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text('¿No tienes cuenta? Regístrate', style: TextStyle(fontSize: small ? 11 : 14)),
                ),
                
                if (WearLayout.isLikelyRound(context))
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}