import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/testimonials_data.dart';
import 'section_container.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.surfaceAlt,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Testimoni',
            title: 'Apa Kata Mereka?',
            description:
                'Contoh ilustrasi pengalaman pengguna setelah menggunakan BisaPNS.id.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          LayoutBuilder(
            builder: (context, c) {
              final columns = Responsive.fromWidth(c.maxWidth) == DeviceType.mobile ? 1 : 3;
              const gap = 20.0;
              final itemW = (c.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final t in kTestimonials)
                    SizedBox(width: itemW, child: _TestimonialCard(t)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard(this.item);
  final Testimonial item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_rounded, color: AppColors.star, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          Text('“${item.quote}”', style: AppTextStyles.body.copyWith(color: AppColors.navy)),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(item.initial,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTextStyles.title.copyWith(fontSize: 15)),
                  Text(item.role, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
