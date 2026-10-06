import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'brand_logo.dart';
import 'landing_actions.dart';
import 'landing_buttons.dart';

class LandingNavbar extends StatelessWidget {
  const LandingNavbar({
    super.key,
    required this.actions,
    required this.onOpenMenu,
    this.height = 68,
  });

  final LandingActions actions;
  final VoidCallback onOpenMenu;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.navbar,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.pagePadding(context)),
            child: Row(
              children: [
                InkWell(onTap: actions.scrollToTop, child: const BrandLogo()),
                const Spacer(),
                if (isDesktop) ...[
                  _NavLink('Beranda', actions.scrollToTop),
                  _NavLink('Fitur', actions.scrollToFeatures),
                  _NavLink('Paket', actions.scrollToPricing),
                  _NavLink('Tentang Kami', actions.scrollToFeatures),
                  _NavLink('FAQ', actions.scrollToFaq),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => actions.goLogin(context),
                    style: TextButton.styleFrom(foregroundColor: AppColors.navy),
                    child: const Text('Masuk', style: AppTextStyles.button),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Daftar Sekarang',
                    onPressed: () => actions.goRegister(context),
                  ),
                ] else
                  IconButton(
                    tooltip: 'Buka menu',
                    onPressed: onOpenMenu,
                    icon: const Icon(Icons.menu_rounded, color: AppColors.navy),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.navy)),
    );
  }
}

/// Isi menu mobile (dipakai sebagai endDrawer di LandingPage).
class LandingMobileMenu extends StatelessWidget {
  const LandingMobileMenu({super.key, required this.actions});

  final LandingActions actions;

  @override
  Widget build(BuildContext context) {
    void tap(VoidCallback fn) {
      Navigator.of(context).pop(); // tutup drawer
      fn();
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BrandLogo(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.navy),
                    tooltip: 'Tutup menu',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _MenuTile('Beranda', Icons.home_rounded, () => tap(actions.scrollToTop)),
              _MenuTile('Fitur', Icons.grid_view_rounded, () => tap(actions.scrollToFeatures)),
              _MenuTile('Paket', Icons.local_offer_rounded, () => tap(actions.scrollToPricing)),
              _MenuTile('Tentang Kami', Icons.info_rounded, () => tap(actions.scrollToFeatures)),
              _MenuTile('FAQ', Icons.help_rounded, () => tap(actions.scrollToFaq)),
              const Spacer(),
              SecondaryButton(
                label: 'Masuk',
                expand: true,
                onPressed: () => tap(() => actions.goLogin(context)),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Daftar Sekarang',
                expand: true,
                onPressed: () => tap(() => actions.goRegister(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.title),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
    );
  }
}
