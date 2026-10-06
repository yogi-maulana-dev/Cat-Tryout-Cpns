import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens — Shadow halus (subtle) untuk kartu & navbar.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0F2A43), // navy 6%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> navbar = [
    BoxShadow(
      color: Color(0x0A0F2A43),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  /// Shadow lebih menonjol untuk kartu ter-highlight (pricing populer / hover).
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.18),
      blurRadius: 32,
      offset: const Offset(0, 14),
    ),
  ];
}
