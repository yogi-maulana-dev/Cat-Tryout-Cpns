import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Kotak pesan (error/sukses) untuk halaman auth — memakai token design system.
class AuthMessageBox extends StatelessWidget {
  const AuthMessageBox({super.key, required this.message, this.success = false});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final base = success ? AppColors.success : AppColors.danger;
    final icon = success ? Icons.check_circle_rounded : Icons.error_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: base.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: base, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, height: 1.35, color: base, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
