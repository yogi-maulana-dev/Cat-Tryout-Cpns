import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Baris skor per kategori (TWK/TIU/TKP): nilai vs skor maks + penanda PG.
class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.label,
    required this.score,
    required this.max,
    required this.passingGrade,
  });

  final String label;
  final int score;
  final int max;
  final int passingGrade;

  @override
  Widget build(BuildContext context) {
    final pct = (max <= 0 ? 0.0 : score / max).clamp(0.0, 1.0);
    final passPct = (max <= 0 ? 0.0 : passingGrade / max).clamp(0.0, 1.0);
    final passed = score >= passingGrade;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Text('$score / $max', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Icon(passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16, color: passed ? AppColors.primary : AppColors.danger),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          return SizedBox(
            height: 12,
            child: Stack(children: [
              Container(decoration: const BoxDecoration(color: Color(0xFFEEF2F6), borderRadius: AppRadius.brPill)),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(decoration: BoxDecoration(
                    color: passed ? AppColors.primary : AppColors.warning, borderRadius: AppRadius.brPill)),
              ),
              Positioned(
                left: (w * passPct).clamp(0, w - 3),
                child: Container(width: 3, height: 12, color: AppColors.marker),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}
