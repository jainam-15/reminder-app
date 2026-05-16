import 'package:flutter/material.dart';

/// Centralized brand color system.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────
  static const deepBlue = Color(0xFF0F4CFF);
  static const cyan = Color(0xFF21D4FD);
  static const success = Color(0xFF22C55E);
  static const orange = Color(0xFFFF8A3D);
  static const destructive = Color(0xFFEF4444);

  // ── Backgrounds ───────────────────────────────────────────
  static const background = Color(0xFF050B14);
  static const surface = Color(0xFF0A1628);
  static const surfaceLight = Color(0xFF111D32);
  static const surfaceElevated = Color(0xFF16243A);

  // ── Glass / Card ──────────────────────────────────────────
  static final cardFill = Colors.white.withValues(alpha: 0.03);
  static final cardBorder = Colors.white.withValues(alpha: 0.05);
  static final cardHighlight = Colors.white.withValues(alpha: 0.04);
  static final innerBorder = Colors.white.withValues(alpha: 0.03);

  // ── Text ──────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textTertiary = Color(0xFF475569);
  static const textMuted = Color(0xFF2E394D);

  // ── Gradients ─────────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, cyan],
  );

  static final glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.04),
      Colors.white.withValues(alpha: 0.01),
    ],
  );
}
