import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Kartu standar: surface, border tipis, radius lg. Opsional onTap & highlight.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.highlighted = false,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
          width: highlighted ? 1.6 : 1,
        ),
      ),
      child: child,
    );

    final card = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            borderRadius: AppRadius.brLg,
            child: InkWell(borderRadius: AppRadius.brLg, onTap: onTap, child: content),
          );

    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}
