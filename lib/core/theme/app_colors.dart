import 'package:flutter/material.dart';

/// Design tokens — Warna brand BisaPNS.id.
///
/// Konsep brand: tunas / pertumbuhan / pembelajaran → hijau profesional di atas
/// latar netral terang. Hijau adalah identitas utama; aksen seperlunya.
/// Nilai disejajarkan dengan brief; nama lama dipertahankan sebagai alias.
class AppColors {
  AppColors._();

  // Primary (brand green)
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryDarker = Color(0xFF116B33);
  static const Color primaryLight = Color(0xFFDCFCE7);

  // Secondary / ink (dark slate)
  static const Color secondary = Color(0xFF0F172A);

  // Secondary background (light green) — alias lama
  static const Color primarySoft = primaryLight;
  static const Color surfaceAlt = Color(0xFFF1FAF4);

  // Base netral
  static const Color background = Color(0xFFF8FAFC); // canvas
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Teks
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color navy = textPrimary; // alias lama (heading)

  // Garis & status
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color star = warning; // alias lama
  static const Color marker = Color(0xFFEF6C3B); // penanda ambang batas (chart)

  // Status nomor soal (Exam engine)
  static const Color answered = primary; // hijau: sudah dijawab
  static const Color unanswered = Color(0xFFCBD5E1); // abu: belum
  static const Color flagged = warning; // kuning: ragu

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceAlt, surface],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// ColorScheme untuk ThemeData aplikasi (Material 3).
  static ColorScheme get scheme => ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: textOnPrimary,
        surface: surface,
        error: danger,
        brightness: Brightness.light,
      );
}
