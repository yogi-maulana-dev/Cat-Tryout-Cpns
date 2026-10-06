import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_container.dart';

/// Data contoh untuk mockup analisis hasil (bukan data nyata).
class _Bar {
  const _Bar(this.label, this.score, this.max, this.pass);
  final String label;
  final int score;
  final int max;
  final int pass;
  double get pct => score / max;
  double get passPct => pass / max;
}

const _bars = [
  _Bar('TWK', 130, 150, 65),
  _Bar('TIU', 115, 175, 80),
  _Bar('TKP', 156, 225, 166),
];

class ResultPreviewSection extends StatelessWidget {
  const ResultPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.background,
      child: ResponsiveBuilder(
        builder: (context, device) {
          const left = _ResultText();
          const right = _ResultDashboard();
          if (device == DeviceType.mobile) {
            return const Column(children: [left, SizedBox(height: AppSpacing.xxl), right]);
          }
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: left),
              SizedBox(width: AppSpacing.xxl),
              Expanded(flex: 6, child: right),
            ],
          );
        },
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText();

  @override
  Widget build(BuildContext context) {
    final center = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Analisis Hasil',
          title: 'Ketahui Perkembangan Belajarmu',
          description:
              'Evaluasi hasil tryout agar kamu tahu bagian mana yang perlu ditingkatkan.',
          center: center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: center ? WrapAlignment.center : WrapAlignment.start,
          children: const [
            _MiniStat(icon: Icons.emoji_events_rounded, value: '401', label: 'Total Skor (contoh)'),
            _MiniStat(icon: Icons.leaderboard_rounded, value: '#128', label: 'Peringkat (contoh)'),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.surfaceAlt, borderRadius: AppRadius.brMd),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark)),
                Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDashboard extends StatelessWidget {
  const _ResultDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Rincian Skor', style: AppTextStyles.title)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration:
                    const BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadius.brPill),
                child: Text('Contoh',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final b in _bars) ...[
            _ScoreBar(b),
            const SizedBox(height: 18),
          ],
          const Row(
            children: [
              _Chip(color: AppColors.primary, label: 'Skor kamu'),
              SizedBox(width: 16),
              _Chip(color: AppColors.marker, label: 'Ambang batas'),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _CountBox('Benar', '58', AppColors.primary)),
              SizedBox(width: 12),
              Expanded(child: _CountBox('Salah', '42', AppColors.marker)),
              SizedBox(width: 12),
              Expanded(child: _CountBox('Persentase', '58%', AppColors.navy)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar(this.bar);
  final _Bar bar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(bar.label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.navy, fontWeight: FontWeight.w700))),
            Text('${bar.score} / ${bar.max}', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          return SizedBox(
            height: 14,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFFEEF2EF), borderRadius: AppRadius.brPill),
                ),
                FractionallySizedBox(
                  widthFactor: bar.pct.clamp(0, 1),
                  child: Container(
                    decoration:
                        const BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.brPill),
                  ),
                ),
                // Penanda ambang batas
                Positioned(
                  left: (w * bar.passPct).clamp(0, w - 3),
                  child: Container(width: 3, height: 14, color: AppColors.marker),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: const BoxDecoration(color: AppColors.surfaceAlt, borderRadius: AppRadius.brMd),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
