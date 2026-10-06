import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../landing/presentation/widgets/brand_logo.dart';

/// Kerangka halaman auth ber-brand BisaPNS.id.
///
/// Desktop (>=1200): split — panel brand hijau di kiri, kartu form di kanan.
/// Tablet & mobile: satu kolom, kartu form di tengah (maks 460px).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: ResponsiveBuilder(
        builder: (context, device) {
          final form = _FormPanel(title: title, subtitle: subtitle, child: child);
          if (device == DeviceType.desktop) {
            return Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(flex: 6, child: form),
              ],
            );
          }
          return form;
        },
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final showLogo = !Responsive.isDesktop(context); // desktop sudah ada logo di panel kiri
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.brXl,
                boxShadow: AppShadows.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLogo) ...[
                    const Center(child: BrandLogo(size: 40)),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(title, style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  static const _points = [
    'Bank soal TWK, TIU, dan TKP',
    'Simulasi CAT yang realistis',
    'Analisis hasil & pembahasan',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.ctaGradient),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.eco_rounded, size: 200, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Icon(Icons.eco_rounded, size: 180, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandLogo(onDark: true, size: 40),
                const SizedBox(height: AppSpacing.xxl),
                Text('Belajar Hari Ini,\nJadi ASN Nanti.',
                    style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Masuk untuk melanjutkan persiapan CPNS-mu bersama BisaPNS.id.',
                  style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: AppSpacing.xl),
                for (final p in _points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(p, style: AppTextStyles.body.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
