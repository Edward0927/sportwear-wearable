import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';
import '../core/services/wearable_service.dart';


class PairingForm extends StatefulWidget {
  final VoidCallback onLogout;

  const PairingForm({super.key, required this.onLogout});

  @override
  State<PairingForm> createState() => _PairingFormState();
}

class _PairingFormState extends State<PairingForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final wearableService = context.read<WearableService>();

    final ok = await wearableService.emparejar(
      deviceId: _deviceIdCtrl.text.toUpperCase(),
      pairingCode: _codeCtrl.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok && wearableService.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wearableService.error!), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = WearLayout.isSmallScreen(context);
    final tiny = WearLayout.isTinyScreen(context);

    return SingleChildScrollView(
      padding: WearLayout.safePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: WearLayout.safeContentWidth(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: widget.onLogout,
                  icon: Icon(Icons.logout_rounded, size: tiny ? 12 : 16),
                  label: Text('Salir', style: TextStyle(fontSize: tiny ? 10 : 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gray600,
                    padding: EdgeInsets.symmetric(horizontal: tiny ? 6 : 12),
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(tiny ? 10 : (small ? 14 : 20)),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.watch_rounded, color: AppColors.accent, size: tiny ? 18 : (small ? 22 : 32)),
                    SizedBox(height: tiny ? 6 : 10),
                    Text(
                      'Vincula tu banda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tiny ? 12 : (small ? 14 : 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tiny ? 4 : 6),
                    Text(
                      tiny
                          ? 'Captura el ID y código de "Mi wearable".'
                          : 'Abre "Mi wearable" en la web SportWear y captura aquí el '
                              'ID del dispositivo y el código de emparejamiento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: tiny ? 9.5 : (small ? 11 : 13),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tiny ? 16 : 28),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _deviceIdCtrl,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: tiny ? 13 : 16),
                      decoration: InputDecoration(
                        labelText: 'Device ID',
                        labelStyle: TextStyle(fontSize: tiny ? 10 : 14),
                        hintText: tiny ? null : 'Ej. SW-4F2A9C',
                        errorMaxLines: 2,
                        errorStyle: TextStyle(fontSize: tiny ? 9 : 12),
                        isDense: tiny,
                        contentPadding: tiny
                            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                            : null,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    SizedBox(height: tiny ? 10 : 16),
                    TextFormField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: tiny ? 13 : 16),
                      decoration: InputDecoration(
                        labelText: tiny ? 'Código' : 'Código de emparejamiento',
                        labelStyle: TextStyle(fontSize: tiny ? 10 : 14),
                        hintText: tiny ? null : 'Ej. 482913',
                        counterText: '',
                        errorMaxLines: 2,
                        errorStyle: TextStyle(fontSize: tiny ? 9 : 12),
                        isDense: tiny,
                        contentPadding: tiny
                            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length != 6) return '6 dígitos';
                        return null;
                      },
                    ),
                    SizedBox(height: tiny ? 14 : 20),
                    SizedBox(
                      height: tiny ? 36 : 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: tiny
                            ? ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4))
                            : null,
                        child: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                              )
                            : Text('VINCULAR', style: TextStyle(fontSize: tiny ? 10 : 14)),
                      ),
                    ),

                    if (WearLayout.isLikelyRound(context))
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
