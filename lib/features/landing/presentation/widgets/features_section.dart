import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/features_data.dart';
import 'section_container.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.background,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Kenapa BisaPNS.id',
            title: 'Kenapa Memilih BisaPNS.id?',
            description:
                'Kami hadir untuk membantu kamu belajar lebih efektif, terarah, dan siap menghadapi seleksi CPNS.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          LayoutBuilder(
            builder: (context, c) {
              final device = Responsive.fromWidth(c.maxWidth);
              final columns = switch (device) {
                DeviceType.desktop => 3,
                DeviceType.tablet => 2,
                DeviceType.mobile => 1,
              };
              const gap = 20.0;
              final itemW = (c.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final f in kFeatures)
                    SizedBox(width: itemW, child: _FeatureCard(f)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard(this.item);
  final FeatureItem item;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: _hover ? (Matrix4.identity()..translateByDouble(0, -6, 0, 1)) : Matrix4.identity(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brLg,
          border: Border.all(color: AppColors.border),
          boxShadow: _hover ? AppShadows.elevated : AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  color: AppColors.primarySoft, borderRadius: AppRadius.brMd),
              child: Icon(widget.item.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 18),
            Text(widget.item.title, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(widget.item.description, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
