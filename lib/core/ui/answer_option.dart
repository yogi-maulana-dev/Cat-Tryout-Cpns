import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Opsi jawaban dengan area sentuh besar & state terpilih yang jelas.
/// [correct]/[wrong] dipakai di mode review (bukan saat mengerjakan).
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label, // A/B/C/D/E
    required this.text,
    this.selected = false,
    this.onTap,
    this.correct = false,
    this.wrong = false,
    this.imageUrl,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final bool correct;
  final bool wrong;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color bg = AppColors.surface;
    Color badgeBg = const Color(0xFFF1F5F9);
    Color badgeFg = AppColors.textSecondary;

    if (correct) {
      border = AppColors.primary;
      bg = AppColors.primaryLight;
      badgeBg = AppColors.primary;
      badgeFg = Colors.white;
    } else if (wrong) {
      border = AppColors.danger;
      bg = const Color(0xFFFEF2F2);
      badgeBg = AppColors.danger;
      badgeFg = Colors.white;
    } else if (selected) {
      border = AppColors.primary;
      bg = AppColors.primaryLight;
      badgeBg = AppColors.primary;
      badgeFg = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          borderRadius: AppRadius.brMd,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.brMd,
              border: Border.all(color: border, width: selected || correct || wrong ? 1.6 : 1),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: badgeBg, borderRadius: AppRadius.brSm),
                child: Text(label, style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (text.isNotEmpty)
                    Text(text, style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textPrimary)),
                  if (imageUrl != null) ...[
                    if (text.isNotEmpty) const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadius.brSm,
                      child: Image.network(imageUrl!, height: 120, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    ),
                  ],
                ]),
              ),
              if (correct) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
              if (wrong) const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}
