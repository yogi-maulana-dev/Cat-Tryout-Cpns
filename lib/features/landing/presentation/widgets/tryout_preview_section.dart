import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_container.dart';

class TryoutPreviewSection extends StatelessWidget {
  const TryoutPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.surfaceAlt,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Pengalaman Ujian',
            title: 'Rasakan Simulasi CAT yang Realistis',
            description:
                'Kerjakan soal dalam suasana simulasi yang dirancang menyerupai pengalaman ujian.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          ResponsiveBuilder(
            builder: (context, device) {
              final mockup = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const _CatMockup(),
              );
              if (device == DeviceType.mobile) return mockup;
              return Center(child: mockup);
            },
          ),
        ],
      ),
    );
  }
}

class _CatMockup extends StatelessWidget {
  const _CatMockup();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Contoh tampilan simulasi CAT: timer, soal, pilihan jawaban, dan navigasi soal',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brLg,
          boxShadow: AppShadows.card,
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Simulasi CAT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.brPill),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.white, size: 15),
                        SizedBox(width: 5),
                        Text('01:24:32',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Soal 12 dari 100', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Text(
                    'Sikap yang mencerminkan nilai persatuan dalam kehidupan bermasyarakat adalah…',
                    style: AppTextStyles.title.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const _Option('A', 'Mengutamakan kelompok sendiri', false),
                  const _Option('B', 'Menghargai perbedaan dan gotong royong', true),
                  const _Option('C', 'Bersikap acuh terhadap lingkungan', false),
                  const _Option('D', 'Memaksakan pendapat pribadi', false),
                  const SizedBox(height: 16),
                  // Navigasi soal
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 1; i <= 15; i++)
                        _QNav(i, done: const [1, 2, 3, 5, 8, 11].contains(i), current: i == 12),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.bookmark_border_rounded, size: 16),
                        label: const Text('Tandai'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      const Spacer(),
                      const TextButton(onPressed: null, child: Text('Sebelumnya')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        child: const Text('Berikutnya'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option(this.letter, this.text, this.selected);
  final String letter;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18, color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$letter. $text',
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.primaryDark : AppColors.navy,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
        ],
      ),
    );
  }
}

class _QNav extends StatelessWidget {
  const _QNav(this.n, {required this.done, required this.current});
  final int n;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (current) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else if (done) {
      bg = AppColors.primarySoft;
      fg = AppColors.primaryDark;
    } else {
      bg = const Color(0xFFF0F2F1);
      fg = AppColors.textSecondary;
    }
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brSm),
      child: Text('$n',
          style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}
