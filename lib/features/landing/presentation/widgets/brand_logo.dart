import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Logo/brand mark BisaPNS.id.
///
/// CATATAN: Belum ada file logo resmi di `assets/`. Widget ini adalah
/// *placeholder* yang konsisten dengan konsep brand (tunas/buku/pertumbuhan)
/// dan mudah diganti: taruh `assets/images/logo.png`, daftarkan di
/// pubspec.yaml, lalu ganti bagian mark di bawah dengan `Image.asset(...)`.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.onDark = false, this.size = 34, this.showText = true});

  final bool onDark;
  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : AppColors.navy;

    return Semantics(
      label: 'BisaPNS.id',
      image: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mark: kotak hijau berisi buku + tunas (placeholder).
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              gradient: AppColors.ctaGradient,
              borderRadius: AppRadius.brMd,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: size * 0.55),
                Positioned(
                  top: size * 0.12,
                  child: Icon(Icons.eco_rounded,
                      color: Colors.white.withValues(alpha: 0.95), size: size * 0.34),
                ),
              ],
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: AppTextStyles.h3.copyWith(color: textColor, fontSize: size * 0.52),
                children: const [
                  TextSpan(text: 'BisaPNS'),
                  TextSpan(text: '.id', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
