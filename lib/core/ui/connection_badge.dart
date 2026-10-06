import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Status sinkronisasi jawaban saat ujian (subtle, tidak mengganggu).
enum SaveStatus { saved, saving, offline }

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status});
  final SaveStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      SaveStatus.saved => ('Tersimpan', AppColors.primary, Icons.cloud_done_rounded),
      SaveStatus.saving => ('Menyimpan…', AppColors.textSecondary, Icons.cloud_sync_rounded),
      SaveStatus.offline => ('Offline', AppColors.danger, Icons.cloud_off_rounded),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: AppRadius.brPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        status == SaveStatus.saving
            ? SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
