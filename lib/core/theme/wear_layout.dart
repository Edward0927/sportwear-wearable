import 'package:flutter/material.dart';

/// Utilidades de layout para pantallas de Wear OS. Los relojes suelen tener
/// pantallas muy pequeñas (~192-240dp) y, si son redondas, el contenido
/// pegado a las esquinas se corta. Estas funciones dan paddings seguros y
/// detectan si probablemente estamos en una pantalla redonda (ancho ≈ alto,
/// típico de watch faces circulares; los teléfonos son mucho más altos que
/// anchos).
class WearLayout {
  static bool isLikelyRound(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ratio = size.width / size.height;
    return ratio > 0.85 && ratio < 1.15;
  }

  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide < 260;
  }

  /// Relojes muy chicos (ej. "Wear OS Small Round", ~192dp lógicos).
  /// Aquí conviene simplificar el layout (apilar en vez de usar columnas)
  /// en vez de solo reducir fuentes.
  static bool isTinyScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide < 220;
  }

  /// Padding seguro: proporcional al tamaño de pantalla (no un valor fijo),
  /// porque en un reloj de ~192dp un padding fijo de 24 por lado ya se come
  /// una cuarta parte de la pantalla. En pantallas redondas usa un poco más
  /// de margen (~13.5% del ancho, afinado para el caso real de 192dp ≈ 26dp)
  /// para que el contenido no quede cortado por las esquinas del círculo.
  static EdgeInsets safePadding(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final round = isLikelyRound(context);
    final horizontal = (size.width * (round ? 0.135 : 0.06)).clamp(10.0, 28.0);
    final vertical = (size.height * (round ? 0.075 : 0.05)).clamp(8.0, 20.0);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Ancho máximo seguro para contenido que debe verse completo sin
  /// importar en qué posición vertical del scroll caiga (ej. botones de
  /// ancho completo). En una pantalla redonda, solo el centro vertical
  /// exacto tiene el ancho completo del diámetro; el resto se recorta por
  /// la curva. El cuadrado inscrito exacto en el círculo tiene lado =
  /// diámetro × 0.7071; usamos 0.62 (más angosto) para dejar margen real
  /// de seguridad, no solo el límite teórico exacto.
  static double safeContentWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!isLikelyRound(context)) return size.width;
    return size.shortestSide * 0.66;
  }
}
