import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens — Gaya teks. Memakai font default aplikasi (tanpa menambah
/// dependency font baru). Ukuran dasar untuk desktop; helper `scale` dipakai
/// section untuk memperkecil di mobile.
class AppTextStyles {
  AppTextStyles._();

  static const String? _family = null; // pakai font bawaan (Roboto)

  static const TextStyle display = TextStyle(
    fontFamily: _family,
    fontSize: 48,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: AppColors.navy,
    letterSpacing: -0.5,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _family,
    fontSize: 36,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.navy,
    letterSpacing: -0.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.8,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Salin style dengan ukuran font di-skala (untuk responsif mobile/tablet).
  static TextStyle scaled(TextStyle base, double factor) =>
      base.copyWith(fontSize: (base.fontSize ?? 16) * factor);
}
