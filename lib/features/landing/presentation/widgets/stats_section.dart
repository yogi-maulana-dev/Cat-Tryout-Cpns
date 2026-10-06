import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/stats_data.dart';
import 'section_container.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      vertical: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Transform.translate(
          offset: const Offset(0, -28), // efek "floating" sedikit naik
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.brXl,
              boxShadow: AppShadows.card,
              border: Border.all(color: AppColors.border),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                final columns = Responsive.fromWidth(c.maxWidth) == DeviceType.mobile ? 2 : 4;
                const gap = 16.0;
                final itemW = (c.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final s in kStats)
                      SizedBox(width: itemW, child: _StatTile(s)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.item);
  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
              color: AppColors.primarySoft, borderRadius: AppRadius.brMd),
          child: Icon(item.icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 10),
        Text(item.value,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark)),
        const SizedBox(height: 2),
        Text(item.label, textAlign: TextAlign.center, style: AppTextStyles.caption),
      ],
    );
  }
}
