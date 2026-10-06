import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Kartu paket membership (model-agnostic). Dipakai layar Paket & Profil.
class MembershipCard extends StatelessWidget {
  const MembershipCard({
    super.key,
    required this.name,
    required this.priceText,
    this.periodText,
    required this.features,
    this.popular = false,
    this.ctaLabel = 'Pilih Paket',
    this.onSelect,
    this.enabled = true,
  });

  final String name;
  final String priceText;
  final String? periodText;
  final List<String> features;
  final bool popular;
  final String ctaLabel;
  final VoidCallback? onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      highlighted: popular,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          if (popular) const StatusBadge(label: 'Populer', tone: BadgeTone.success),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(priceText, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          if (periodText != null) ...[
            const SizedBox(width: 4),
            Text(periodText!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ]),
        const SizedBox(height: 14),
        for (final f in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(f, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary))),
            ]),
          ),
        const SizedBox(height: 8),
        PrimaryButton(label: ctaLabel, onPressed: enabled ? onSelect : null),
      ]),
    );
  }
}
