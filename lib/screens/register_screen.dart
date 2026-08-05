import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../core/services/api_exception.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';
import '../widgets/legal_dialog.dart';
import 'pairing_flow_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  bool _loading = false;
  bool _aceptaTerminos = false;
  bool _mostrarErrorTerminos = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaTerminos) {
      setState(() => _mostrarErrorTerminos = true);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().register(
            nombre: _nombreCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            telefono: _telefonoCtrl.text.trim(),
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
    final tiny = WearLayout.isTinyScreen(context);
    final screenHeight = MediaQuery.of(context).size.height;

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crear cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: small ? 15 : 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: small ? 12 : 20),
                TextFormField(
                  controller: _nombreCtrl,
                  style: TextStyle(fontSize: small ? 12 : 16),
                  decoration: InputDecoration(
                    labelText: small ? 'Nombre' : 'Nombre completo',
                    labelStyle: TextStyle(fontSize: small ? 11 : 14),
                    errorMaxLines: 2,
                    errorStyle: TextStyle(fontSize: small ? 9 : 12),
                  ),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Requerido' : null,
                ),
                SizedBox(height: small ? 10 : 16),
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
                    if (v == null || v.trim().isEmpty) return 'Requerido';
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
                    labelText: small ? 'Contraseña' : 'Contraseña (mín. 8 caracteres)',
                    labelStyle: TextStyle(fontSize: small ? 11 : 14),
                    errorMaxLines: 2,
                    errorStyle: TextStyle(fontSize: small ? 9 : 12),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return small ? 'Mín. 8' : 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                
                if (!tiny) ...[
                  SizedBox(height: small ? 10 : 16),
                  TextFormField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: small ? 13 : 16),
                    decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                  ),
                ],
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
                        : Text('CREAR CUENTA', style: TextStyle(fontSize: small ? 9 : 14)),
                  ),
                ),
                SizedBox(height: small ? 10 : 14),
                InkWell(
                  onTap: () => setState(() {
                    _aceptaTerminos = !_aceptaTerminos;
                    if (_aceptaTerminos) _mostrarErrorTerminos = false;
                  }),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: small ? 16 : 20,
                        height: small ? 16 : 20,
                        child: Checkbox(
                          value: _aceptaTerminos,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (v) => setState(() {
                            _aceptaTerminos = v ?? false;
                            if (_aceptaTerminos) _mostrarErrorTerminos = false;
                          }),
                        ),
                      ),
                      SizedBox(width: small ? 6 : 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: small ? 9 : 11, color: AppColors.gray600, height: 1.3),
                            children: [
                              const TextSpan(text: 'Acepto los '),
                              TextSpan(
                                text: 'Términos de uso',
                                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => LegalDialog.show(context, esPrivacidad: false),
                              ),
                              const TextSpan(text: ' y el '),
                              TextSpan(
                                text: 'Aviso de privacidad',
                                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => LegalDialog.show(context, esPrivacidad: true),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_mostrarErrorTerminos) ...[
                  SizedBox(height: small ? 4 : 6),
                  Text(
                    'Debes aceptar los términos para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.red, fontSize: small ? 9 : 12),
                  ),
                ],
                
                if (WearLayout.isLikelyRound(context)) SizedBox(height: screenHeight * 0.35),
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