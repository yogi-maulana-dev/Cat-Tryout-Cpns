import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'landing_actions.dart';
import 'landing_buttons.dart';
import 'section_container.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key, required this.actions});
  final LandingActions actions;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.background,
      child: ClipRRect(
        borderRadius: AppRadius.brXl,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.ctaGradient),
          padding: EdgeInsets.symmetric(
            vertical: Responsive.value(context, mobile: 40, desktop: 56),
            horizontal: Responsive.value(context, mobile: 24, desktop: 48),
          ),
          child: Stack(
            children: [
              // Daun dekoratif
              Positioned(
                right: -16,
                top: -16,
                child: Icon(Icons.eco_rounded,
                    size: 140, color: Colors.white.withValues(alpha: 0.10)),
              ),
              Positioned(
                left: -20,
                bottom: -30,
                child: Icon(Icons.eco_rounded,
                    size: 120, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Column(
                children: [
                  Text(
                    'Jangan Tunda Persiapanmu',
                    textAlign: TextAlign.center,
                    style: (Responsive.isMobile(context)
                            ? AppTextStyles.scaled(AppTextStyles.h1, 0.72)
                            : AppTextStyles.h1)
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Mulai belajar sekarang dan persiapkan langkahmu menuju ASN.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      PrimaryButton(
                        label: 'Mulai Belajar Gratis',
                        icon: Icons.arrow_forward_rounded,
                        onDark: true,
                        onPressed: () => actions.goRegister(context),
                      ),
                      SecondaryButton(
                        label: 'Lihat Paket',
                        onDark: true,
                        onPressed: actions.scrollToPricing,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
