import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum QNumStatus { unanswered, answered, flagged }

/// Sel nomor soal untuk navigator (grid). Warna sesuai status + penanda aktif.
class QuestionNumber extends StatelessWidget {
  const QuestionNumber({
    super.key,
    required this.number,
    required this.status,
    this.active = false,
    this.onTap,
    this.size = 40,
  });

  final int number;
  final QNumStatus status;
  final bool active;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      QNumStatus.answered => (AppColors.answered, Colors.white),
      QNumStatus.flagged => (AppColors.flagged, Colors.white),
      QNumStatus.unanswered => (const Color(0xFFF1F5F9), AppColors.textSecondary),
    };
    return InkWell(
      borderRadius: AppRadius.brMd,
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.brMd,
          border: active ? Border.all(color: AppColors.primaryDark, width: 2.5) : null,
        ),
        child: Text('$number', style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
