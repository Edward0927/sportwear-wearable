import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';


class LegalDialog {
  static void show(BuildContext context, {required bool esPrivacidad}) {
    final small = WearLayout.isSmallScreen(context);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(small ? 6 : 16),
        child: ClipRRect(
          
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppColors.black,
            padding: EdgeInsets.fromLTRB(
              WearLayout.safePadding(ctx).horizontal / 2,
              small ? 14 : 24,
              WearLayout.safePadding(ctx).horizontal / 2,
              small ? 10 : 16,
            ),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.92),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  esPrivacidad ? 'Aviso de privacidad' : 'Términos de uso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: small ? 12 : 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: small ? 6 : 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      esPrivacidad ? _privacidad : _terminos,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white70, fontSize: small ? 9.5 : 12, height: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: small ? 6 : 12),
                SizedBox(
                  height: small ? 26 : 36,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 0),
                      padding: EdgeInsets.symmetric(horizontal: small ? 14 : 22),
                    ),
                    child: Text('Entendido', style: TextStyle(fontSize: small ? 9 : 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _privacidad = '''
1. Responsable del tratamiento
SportWear Store, con domicilio en Querétaro, es responsable del uso y protección de tus datos.

2. Datos que recopilamos
Datos de contacto, de tu cuenta y pedidos, y — si vinculas tu SportWear Band — actividad física (ritmo cardiaco, pasos, calorías, distancia).

3. Datos del wearable
Al emparejar tu banda, la actividad se sincroniza con tu perfil para mostrarte tu historial. Puedes desvincularla cuando quieras.

4. Finalidad
Procesar pedidos, brindar soporte, personalizar recomendaciones y mejorar nuestros servicios.

5. Con quién compartimos
No vendemos tus datos. Solo los compartimos con proveedores de logística y pago para completar tu compra.

6. Tus derechos
Puedes solicitar acceso, rectificación o cancelación escribiendo a privacidad@sportwear.mx.

7. Cambios
Podemos actualizar este aviso periódicamente.''';

  static const _terminos = '''
1. Aceptación
Al usar el sitio, la app y el wearable SportWear Band aceptas estos términos en su totalidad.

2. Tu cuenta
Eres responsable de tu contraseña y de toda actividad bajo tu cuenta.

3. Wearable y app
El emparejamiento es responsabilidad del usuario. La banda no es un dispositivo médico.

4. Propiedad intelectual
Todo el contenido es propiedad de SportWear Store.

5. Responsabilidad
No respondemos por daños indirectos derivados del uso del sitio, la app o el wearable.

6. Contacto
Dudas: hola@sportwear.mx.''';
}
