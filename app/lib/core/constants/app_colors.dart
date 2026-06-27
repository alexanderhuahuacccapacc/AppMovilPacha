import 'package:flutter/material.dart';

/// Official Hotel Pacha Suite palette, shared with the Angular web app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC2410C); // naranja quemado
  static const Color primaryDark = Color(0xFF9A3412); // naranja oscuro
  static const Color amber = Color(0xFFD97706); // ámbar
  static const Color chocolate = Color(0xFF5C3A21); // café chocolate
  static const Color creamLight = Color(0xFFFAF7F2); // beige claro
  static const Color creamSoft = Color(0xFFF0E9DD); // beige suave
  static const Color textDark = Color(0xFF1F1611); // texto cálido

  static const Color textMuted = Color(0xFF6B5A4E);
  static const Color border = Color(0xFFE8DDD4);
  static const Color white = Color(0xFFFFFFFF);

  // Estados de habitación
  static const Color success = Color(0xFF16A34A); // disponible
  static const Color danger = Color(0xFFC2410C); // ocupada
  static const Color warning = Color(0xFFD97706); // mantenimiento
}
