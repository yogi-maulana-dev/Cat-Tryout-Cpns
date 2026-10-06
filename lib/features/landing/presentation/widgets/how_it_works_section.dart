import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/steps_data.dart';
import 'section_container.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.surfaceAlt,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Cara Belajar',
            title: 'Mulai Belajar Dalam 4 Langkah',
          ),
          const SizedBox(height: AppSpacing.xxl),
          ResponsiveBuilder(
            builder: (context, device) => device == DeviceType.mobile
                ? const _VerticalStepper()
                : const _HorizontalStepper(),
          ),
        ],
      ),
    );
  }
}

class _HorizontalStepper extends StatelessWidget {
  const _HorizontalStepper();

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < kSteps.length; i++) {
      items.add(Expanded(child: _StepCard(index: i, step: kSteps[i])));
      if (i < kSteps.length - 1) {
        items.add(const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
        ));
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }
}

class _VerticalStepper extends StatelessWidget {
  const _VerticalStepper();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kSteps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == kSteps.length - 1 ? 0 : AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepBadge(i),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(kSteps[i].title, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(kSteps[i].description, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});
  final int index;
  final StepItem step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepBadge(index),
        const SizedBox(height: 16),
        Text(step.title, textAlign: TextAlign.center, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(step.description,
              textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge(this.index);
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(kSteps[index].icon, color: AppColors.primary, size: 26),
          Positioned(
            top: -6,
            right: -2,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text('${index + 1}',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
