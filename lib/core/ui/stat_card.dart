import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

/// Kartu statistik ringkas: ikon + nilai besar + label.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.value, required this.label, this.color});

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: c, size: 20),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }
}
