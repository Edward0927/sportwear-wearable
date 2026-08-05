# SportWear Band — App Flutter (identificación del wearable)

Genera las carpetas nativas que faltan (android/ios/etc.)
#    Flutter detecta el pubspec.yaml existente y solo agrega lo que falta.
flutter create .

# 3. Instala las dependencias
flutter pub get

# 4. Corre la app (con un emulador/dispositivo conectado)
flutter run
```
## Flujo de identificación del wearable

1. El usuario **inicia sesión** (o se registra) con la misma cuenta que usa en la web SportWear — llama a `POST /api/auth/login` del backend y guarda el JWT.
2. La app consulta `GET /api/wearable/me`. Si el wearable no está `conectado`, muestra el **formulario de identificación**.
3. En la web Angular (página **"Mi wearable"**) o en la pantalla física del reloj, aparecen un **Device ID** (ej. `SW-4F2A9C`) y un **código de 6 dígitos**.
4. El usuario captura esos dos datos en la app Flutter y toca **"Identificar y vincular"** → `POST /api/wearable/pair`.
5. Si coinciden con lo que generó el backend, el wearable pasa a estado `conectado` y la app muestra el **dashboard** con las métricas.
6. El usuario puede **desvincular** el wearable en cualquier momento (`DELETE /api/wearable/me`), lo que también lo refleja la web Angular.

