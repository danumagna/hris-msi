import 'package:flutter/material.dart';

/// Central color palette for HRIS MSI.
///
/// All colors used across the app are defined here so that
/// the visual identity stays consistent and easy to update.
class AppColors {
  AppColors._();

  // ── Primary Palette ───────────────────────────────────
  static const Color primaryBlue = Color(0xFF6A8EBB);
  static const Color darkBlue = Color(0xFF285FA1);
  static const Color lightBlue = Color(0xFF9FB7D6);
  static const Color accentBlue = Color(0xFF3F6FA8);

  // ── Neutral Palette ───────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8ECF1);
  static const Color border = Color(0xFFD1D9E6);

  // ── Text Palette ──────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A2A3A);
  static const Color textSecondary = Color(0xFF5A6B7D);
  static const Color textHint = Color(0xFF9EAAB8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic Palette ──────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ── Gradient ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, accentBlue, primaryBlue],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, lightBlue],
  );
}
