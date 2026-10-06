import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum BadgeTone { success, warning, danger, info, neutral, premium }

/// Badge status ringkas (pill) dengan warna sesuai tone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral, this.icon});

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  (Color, Color) get _colors => switch (tone) {
        BadgeTone.success => (AppColors.primaryLight, AppColors.primaryDark),
        BadgeTone.warning => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
        BadgeTone.danger => (const Color(0xFFFEE2E2), AppColors.danger),
        BadgeTone.info => (const Color(0xFFDBEAFE), AppColors.info),
        BadgeTone.premium => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
        BadgeTone.neutral => (const Color(0xFFF1F5F9), AppColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
        Text(label, style: TextStyle(color: fg, fontSize: 11.5, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
