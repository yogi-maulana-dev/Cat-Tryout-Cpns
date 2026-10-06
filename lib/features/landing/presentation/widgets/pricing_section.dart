import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/pricing_data.dart';
import 'landing_actions.dart';
import 'landing_buttons.dart';
import 'section_container.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key, required this.actions});
  final LandingActions actions;

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool _yearly = false;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.background,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Harga',
            title: 'Harga yang Fleksibel untuk Semua Kebutuhanmu',
            description:
                'Pilih paket sesuai tujuan dan kebutuhan belajarmu. Mulai dari gratis hingga paket lengkap.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _BillingToggle(
            yearly: _yearly,
            onChanged: (v) => setState(() => _yearly = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, c) {
              final device = Responsive.fromWidth(c.maxWidth);
              final columns = switch (device) {
                DeviceType.desktop => 4,
                DeviceType.tablet => 2,
                DeviceType.mobile => 1,
              };
              const gap = 20.0;
              final itemW = (c.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                alignment: WrapAlignment.center,
                children: [
                  for (final plan in kPricingPlans)
                    SizedBox(
                      width: itemW,
                      child: _PricingCard(
                        plan: plan,
                        yearly: _yearly,
                        // Semua CTA paket mengarah ke registrasi (mock, tanpa checkout).
                        onSelect: () => widget.actions.goRegister(context),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Harga adalah contoh dan dapat berubah sewaktu-waktu.',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.yearly, required this.onChanged});
  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget label(String text, bool active) => Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: active ? AppColors.navy : AppColors.textSecondary,
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label('Bulanan', !yearly),
        const SizedBox(width: 12),
        Semantics(
          toggled: yearly,
          label: 'Periode tagihan tahunan',
          child: GestureDetector(
            key: const Key('pricing_billing_toggle'),
            onTap: () => onChanged(!yearly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: yearly ? AppColors.primary : const Color(0xFFCFE9DB),
                borderRadius: AppRadius.brPill,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: yearly ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        label('Tahunan', yearly),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadius.brPill),
          child: Text('Hemat',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.plan, required this.yearly, required this.onSelect});
  final PricingPlan plan;
  final bool yearly;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final highlighted = plan.highlighted;
    final price = plan.priceFor(yearly);
    final period = price == 0 ? '/selamanya' : (yearly ? '/tahun' : '/bulan');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: highlighted ? AppShadows.elevated : AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.name, style: AppTextStyles.h3)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: highlighted ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  plan.label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: highlighted ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(formatRupiah(price),
                    style: AppTextStyles.h1.copyWith(fontSize: 30), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              Text(period, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: plan.ctaText,
            expand: true,
            onPressed: onSelect,
          ),
          const SizedBox(height: 20),
          for (final f in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: AppTextStyles.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
