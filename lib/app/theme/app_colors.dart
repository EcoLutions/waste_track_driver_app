import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58D68D);
  static const Color primaryDark = Color(0xFF229954);

  // ==================== SECONDARY COLORS ====================
  static const Color secondary = Color(0xFF3498DB);
  static const Color secondaryLight = Color(0xFF5DADE2);
  static const Color secondaryDark = Color(0xFF2874A6);

  // ==================== ACCENT COLORS ====================
  static const Color accent = Color(0xFFF39C12);
  static const Color accentLight = Color(0xFFF5B041);
  static const Color accentDark = Color(0xFFD68910);

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ==================== NEUTRAL COLORS ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF95A5A6);
  static const Color greyLight = Color(0xFFECF0F1);
  static const Color greyDark = Color(0xFF7F8C8D);

  // ==================== BACKGROUND COLORS ====================
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C3E50);

  // ==================== TEXT COLORS ====================
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textDisabled = Color(0xFFECF0F1);

  // ==================== CONTAINER STATUS COLORS ====================
  /// Para niveles de llenado de contenedores
  static const Color containerEmpty = Color(0xFF2ECC71);
  static const Color containerMedium = Color(0xFFF39C12);
  static const Color containerFull = Color(0xFFE74C3C);
}