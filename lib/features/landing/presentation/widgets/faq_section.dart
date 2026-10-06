import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/faq_data.dart';
import 'section_container.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: AppColors.background,
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'FAQ',
            title: 'Pertanyaan yang Sering Diajukan',
          ),
          const SizedBox(height: AppSpacing.xxl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              children: [
                for (var i = 0; i < kFaqs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FaqTile(item: kFaqs[i], initiallyOpen: i == 0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item, this.initiallyOpen = false});
  final FaqItem item;
  final bool initiallyOpen;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _open ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: _open ? AppColors.primary : AppColors.border),
      ),
      child: Theme(
        // Hilangkan garis default ExpansionTile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyOpen,
          onExpansionChanged: (v) => setState(() => _open = v),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          collapsedShape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(widget.item.question,
              style: AppTextStyles.title
                  .copyWith(color: _open ? AppColors.primaryDark : AppColors.navy)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.item.answer, style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
