import 'package:flutter/material.dart';

import '../../../../core/money.dart';
import '../../../../core/promo.dart';
import '../../../../core/promo_config.dart';
import '../../../../core/responsive.dart';
import '../../../../core/server_clock.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/promo_countdown.dart';
import '../../../../core/wib.dart';
import 'landing_actions.dart';
import 'landing_buttons.dart';
import 'section_container.dart';

/// Section harga landing: tiga kartu paket (Bronze / Gold / Platinum) dengan
/// promo Platinum (harga coret, diskon, countdown). Promo & harga memakai
/// definisi di [kPackageCatalog].
///
/// Catatan: pada landing (publik, tanpa sesi), countdown dihitung dari jam
/// perangkat. Pada alur berbayar (login), countdown & harga memakai waktu
/// server (lihat `ServerClock` di `PackagesScreen`). Penegakan harga promo
/// tetap dilakukan server saat order dibuat.
class PricingSection extends StatelessWidget {
  PricingSection({super.key, required this.actions});
  final LandingActions actions;
  final ServerClock _clock = ServerClock.fromDevice();

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
                'Pilih paket sesuai kebutuhan belajarmu. Mulai dari Bronze gratis hingga Platinum paling lengkap.',
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, c) {
              final device = Responsive.fromWidth(c.maxWidth);
              final columns = switch (device) {
                DeviceType.desktop => 3,
                DeviceType.tablet => 3,
                DeviceType.mobile => 1,
              };
              const gap = 20.0;
              final itemW = (c.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                alignment: WrapAlignment.center,
                children: [
                  for (final plan in kPackageCatalog)
                    SizedBox(
                      width: itemW,
                      child: _PlanCard(
                        plan: plan,
                        clock: _clock,
                        onSelect: () => actions.goRegister(context),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Harga dapat berubah sesuai kebijakan promo. Harga final dikonfirmasi saat checkout.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({required this.plan, required this.clock, required this.onSelect});
  final PackageTierConfig plan;
  final ServerClock clock;
  final VoidCallback onSelect;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  PackageTierConfig get plan => widget.plan;

  PromoState get _state {
    final w = plan.promoWindow;
    if (w == null || plan.promoPrice == null) return PromoState.none;
    return w.stateAt(widget.clock.now());
  }

  Color get _accent {
    switch (plan.slug) {
      case 'platinum':
        return AppColors.info;
      case 'gold':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final promoActive = state == PromoState.active;
    final highlighted = plan.slug == 'platinum';
    final price = promoActive ? plan.promoPrice! : plan.normalPrice;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: highlighted ? _accent : AppColors.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: highlighted ? AppShadows.elevated : AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: Text(plan.name, style: AppTextStyles.h3)),
            if (promoActive)
              _badge('PROMO ${plan.discount}%', AppColors.danger)
            else if (plan.isPopular)
              _badge('POPULER', _accent)
            else if (plan.slug == 'platinum')
              _badge('UNGGULAN', _accent)
            else if (plan.isFree)
              _badge('GRATIS', _accent),
          ]),
          const SizedBox(height: 6),
          Text(plan.tagline, style: AppTextStyles.caption),
          const SizedBox(height: 16),

          // Harga (coret + promo bila aktif)
          if (promoActive) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(rupiah(plan.normalPrice),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  )),
              const SizedBox(width: 8),
              _badge('-${plan.discount}%', AppColors.danger),
            ]),
            const SizedBox(height: 2),
          ],
          Text(rupiah(price), style: AppTextStyles.h1.copyWith(fontSize: 30)),

          // Countdown / status promo
          if (promoActive && plan.promoWindow != null) ...[
            const SizedBox(height: 14),
            _promoBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.local_fire_department_rounded, size: 15, color: AppColors.danger),
                  SizedBox(width: 6),
                  Text('Promo berakhir dalam',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ]),
                const SizedBox(height: 8),
                PromoCountdown(
                  clock: widget.clock,
                  endsAt: plan.promoWindow!.endsAt,
                  onEnded: () => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text('s/d ${formatWib(plan.promoWindow!.endsAt)}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ]),
            ),
          ] else if (state == PromoState.notStarted && plan.promoWindow != null) ...[
            const SizedBox(height: 12),
            Text('Promo mulai ${formatWib(plan.promoWindow!.startsAt)}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.info, fontWeight: FontWeight.w600)),
          ],

          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill(Icons.event_available_rounded, 'Aktif ${plan.durationDays} hari'),
            _pill(Icons.assignment_turned_in_rounded, '${plan.tryoutQuota}x try out'),
          ]),
          const SizedBox(height: 16),
          PrimaryButton(
            label: plan.isFree ? 'Mulai Gratis' : 'Pilih Paket',
            expand: true,
            onPressed: widget.onSelect,
          ),
          const SizedBox(height: 18),
          for (final f in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: AppTextStyles.bodySmall)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.brPill),
        child: Text(text,
            style: AppTextStyles.caption
                .copyWith(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
      );

  Widget _promoBox({required Widget child}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.06),
          borderRadius: AppRadius.brMd,
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
        ),
        child: child,
      );

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      );
}
