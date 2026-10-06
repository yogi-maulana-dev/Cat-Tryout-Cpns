import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Tombol utama (brand green, pill). Mendukung ikon trailing opsional.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.onDark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expand;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final bg = onDark ? Colors.white : AppColors.primary;
    final fg = onDark ? AppColors.primaryDark : Colors.white;

    final child = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        textStyle: AppTextStyles.button,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Tombol sekunder (outline). Untuk "Lihat Demo", "Lihat Paket", dll.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.onDark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expand;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Colors.white : AppColors.primaryDark;
    final side = BorderSide(color: onDark ? Colors.white70 : AppColors.primary, width: 1.5);

    final child = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: side,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        textStyle: AppTextStyles.button,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}
