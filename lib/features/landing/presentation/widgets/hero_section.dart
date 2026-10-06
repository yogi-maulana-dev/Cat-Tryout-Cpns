import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'landing_actions.dart';
import 'landing_buttons.dart';
import 'section_container.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.actions});

  final LandingActions actions;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      gradient: AppColors.heroGradient,
      child: ResponsiveBuilder(
        builder: (context, device) {
          final text = _HeroText(actions: actions, device: device);

          if (device != DeviceType.desktop) {
            return Column(
              children: [
                text,
                const SizedBox(height: AppSpacing.xxl),
                const _HeroVisual(),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: text),
              const SizedBox(width: AppSpacing.xxl),
              const Expanded(flex: 5, child: _HeroVisual()),
            ],
          );
        },
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.actions, required this.device});
  final LandingActions actions;
  final DeviceType device;

  @override
  Widget build(BuildContext context) {
    final isDesktop = device == DeviceType.desktop;
    final align = isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;
    final headingBase = isDesktop
        ? AppTextStyles.display
        : AppTextStyles.scaled(AppTextStyles.display, device == DeviceType.tablet ? 0.8 : 0.62);

    return Column(
      crossAxisAlignment: align,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.brPill,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Platform Tryout CPNS Terpercaya',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Heading dua warna
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            style: headingBase,
            children: const [
              TextSpan(text: 'Persiapkan Diri Menuju\n'),
              TextSpan(text: 'Karier ASN Impianmu', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            'Latihan soal CPNS lengkap, update, dan sesuai kisi-kisi terbaru. '
            'Tingkatkan kesiapan menghadapi ujian dengan simulasi CAT yang realistis '
            'dan pembahasan yang mudah dipahami.',
            textAlign: textAlign,
            style: AppTextStyles.body,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // CTA
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            PrimaryButton(
              label: 'Mulai Belajar Gratis',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => actions.goRegister(context),
            ),
            SecondaryButton(
              label: 'Lihat Demo',
              icon: Icons.play_circle_outline_rounded,
              onPressed: actions.scrollToDemo,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Tidak perlu langsung berlangganan. Coba terlebih dahulu.',
            textAlign: textAlign, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xl),

        // Selling points
        _SellingPoints(device: device),
      ],
    );
  }
}

class _SellingPoints extends StatelessWidget {
  const _SellingPoints({required this.device});
  final DeviceType device;

  static const _points = [
    ('Soal Terupdate', 'Sesuai Kisi-Kisi Terbaru', Icons.fact_check_rounded),
    ('Simulasi CAT', 'Realistis & Terstruktur', Icons.computer_rounded),
    ('Pembahasan Lengkap', 'Mudah Dipahami', Icons.lightbulb_rounded),
    ('Akses Fleksibel', 'Di Semua Perangkat', Icons.devices_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = device == DeviceType.mobile ? 1 : 2;
    return LayoutBuilder(builder: (context, c) {
      const gap = 16.0;
      final itemWidth = columns == 1 ? c.maxWidth : (c.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final p in _points)
            SizedBox(
              width: itemWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: AppColors.primarySoft, borderRadius: AppRadius.brSm),
                    child: Icon(p.$3, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$1, style: AppTextStyles.title.copyWith(fontSize: 15)),
                        Text(p.$2, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

/// Visual hero (placeholder elegan, tanpa external image URL).
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ilustrasi peserta CPNS belajar menggunakan perangkat digital',
      child: AspectRatio(
        aspectRatio: 1.02,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primarySoft, Color(0xFFDFF3E7)],
            ),
            borderRadius: AppRadius.brXl,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Decorative leaf
              Positioned(
                right: -10,
                top: -10,
                child: Icon(Icons.eco_rounded,
                    size: 120, color: AppColors.primary.withValues(alpha: 0.12)),
              ),
              // Decorative text
              const Positioned(
                left: 24,
                top: 24,
                child: Text(
                  'Mimpi\nBukan Sekadar\nMimpi',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              // Kartu skor mengambang
              const Positioned(
                right: 22,
                top: 90,
                child: _FloatingCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Skor Tryout',
                  value: '401',
                  subtitle: 'Contoh hasil',
                ),
              ),
              // Kartu progress mengambang
              const Positioned(
                left: 22,
                bottom: 24,
                child: _FloatingCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Progres Belajar',
                  value: '+18%',
                  subtitle: 'Minggu ini (contoh)',
                ),
              ),
              // Avatar besar (person placeholder)
              Center(
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Icon(Icons.school_rounded, size: 64, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, borderRadius: AppRadius.brSm),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.title.copyWith(color: AppColors.primaryDark)),
              Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}
