import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Pembungkus section: membatasi lebar konten (SaaS-style, max 1200px),
/// memusatkan, dan memberi padding vertikal + horizontal responsif.
class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.child,
    this.background,
    this.vertical = true,
    this.gradient,
  });

  final Widget child;
  final Color? background;
  final Gradient? gradient;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final vPad = Responsive.value<double>(
      context,
      mobile: AppSpacing.sectionMobile,
      desktop: AppSpacing.section,
    );
    final hPad = Responsive.pagePadding(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: background, gradient: gradient),
      padding: EdgeInsets.symmetric(
        vertical: vertical ? vPad : 0,
        horizontal: hPad,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Judul section standar: eyebrow kecil + heading + deskripsi opsional.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.description,
    this.center = true,
    this.titleColor,
  });

  final String? eyebrow;
  final String title;
  final String? description;
  final bool center;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(),
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.eyebrow),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: (Responsive.isMobile(context)
                  ? AppTextStyles.scaled(AppTextStyles.h2, 0.82)
                  : AppTextStyles.h2)
              .copyWith(color: titleColor),
        ),
        if (description != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              description!,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ],
    );
  }
}
