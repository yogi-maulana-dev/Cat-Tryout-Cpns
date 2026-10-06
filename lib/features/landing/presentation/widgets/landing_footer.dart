import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'brand_logo.dart';
import 'landing_actions.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key, required this.actions});
  final LandingActions actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: EdgeInsets.symmetric(
        vertical: 48,
        horizontal: Responsive.pagePadding(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveBuilder(
                builder: (context, device) {
                  final brand = _BrandBlock(actions: actions);
                  final cols = [
                    _FooterColumn('Navigasi', [
                      ('Beranda', actions.scrollToTop),
                      ('Fitur', actions.scrollToFeatures),
                      ('Paket', actions.scrollToPricing),
                      ('Tentang Kami', actions.scrollToFeatures),
                      ('FAQ', actions.scrollToFaq),
                    ]),
                    const _FooterColumn('Bantuan', [
                      ('Pusat Bantuan', null),
                      ('Kontak', null),
                      ('Kebijakan Privasi', null),
                      ('Syarat & Ketentuan', null),
                    ]),
                    const _FooterColumn('Sosial Media', [
                      ('Instagram', null),
                      ('TikTok', null),
                      ('YouTube', null),
                      ('WhatsApp', null),
                    ]),
                  ];

                  if (device == DeviceType.mobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: AppSpacing.xl),
                        for (final col in cols) ...[
                          col,
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: brand),
                      const SizedBox(width: 32),
                      for (final col in cols) Expanded(flex: 2, child: col),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Divider(color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: AppSpacing.md),
              Text(
                '© BisaPNS.id — Semua hak dilindungi.',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.actions});
  final LandingActions actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(onTap: actions.scrollToTop, child: const BrandLogo(onDark: true)),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Belajar Hari Ini, Jadi ASN Nanti.',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn(this.title, this.links);
  final String title;
  final List<(String, VoidCallback?)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title.copyWith(color: Colors.white)),
        const SizedBox(height: 14),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: link.$2,
              child: Text(link.$1,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            ),
          ),
      ],
    );
  }
}
