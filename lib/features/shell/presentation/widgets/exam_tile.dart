import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../../../../models/exam.dart';

/// Kartu ringkas satu tryout. [locked] untuk premium yang belum member.
class ExamTile extends StatelessWidget {
  const ExamTile({super.key, required this.exam, required this.onTap, this.locked = false, this.trailingLabel});

  final Exam exam;
  final VoidCallback onTap;
  final bool locked;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: locked ? const Color(0xFFFEF3C7) : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            locked ? Icons.lock_rounded : Icons.assignment_rounded,
            color: locked ? const Color(0xFFB45309) : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exam.namaSesi,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text('${exam.durasiMenit} mnt', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (exam.totalSoal > 0) ...[
                const SizedBox(width: 10),
                const Icon(Icons.help_outline_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text('${exam.totalSoal} soal', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ]),
            if (exam.isPremium || exam.isOnsite) ...[
              const SizedBox(height: 6),
              Wrap(spacing: 6, children: [
                if (exam.isPremium) const StatusBadge(label: 'Premium', tone: BadgeTone.premium, icon: Icons.workspace_premium_rounded),
                if (exam.isOnsite) const StatusBadge(label: 'Di Tempat', tone: BadgeTone.info, icon: Icons.location_on_rounded),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        trailingLabel != null
            ? Text(trailingLabel!, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12))
            : Icon(locked ? Icons.lock_rounded : Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    );
  }
}
