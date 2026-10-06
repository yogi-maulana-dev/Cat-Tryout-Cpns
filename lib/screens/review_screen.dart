import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/content_format.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../models/review_question.dart';
import '../services/attempt_service.dart';

class ReviewScreen extends StatefulWidget {
  final String attemptId;
  const ReviewScreen({super.key, required this.attemptId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _service = AttemptService();
  late Future<List<ReviewQuestion>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.review(widget.attemptId);
  }

  void _reload() => setState(() => _future = _service.review(widget.attemptId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembahasan')),
      body: ContentWidth(child: FutureBuilder<List<ReviewQuestion>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Memuat pembahasan…');
          }
          if (snap.hasError) {
            final err = snap.error;
            final msg = err is ApiException ? err.firstError : '$err';
            // 403 → sesi tak mengizinkan pembahasan: tampilkan sebagai info terkunci.
            return EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Pembahasan tidak tersedia',
              message: msg,
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const EmptyState(icon: Icons.menu_book_outlined, title: 'Belum ada pembahasan');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) => _ReviewCard(item: items[i]),
            ),
          );
        },
      )),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewQuestion item;
  const _ReviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // is_correct null = tipe weighted (TKP) atau tak dijawab → netral.
    final (badgeTone, badgeLabel) = !item.dijawab
        ? (BadgeTone.neutral, 'Kosong')
        : item.isCorrect == true
            ? (BadgeTone.success, 'Benar')
            : item.isCorrect == false
                ? (BadgeTone.danger, 'Salah')
                : (BadgeTone.info, 'Skor +${item.scoreEarned}');

    final imageUrl = resolveImageUrl(item.questionImage);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            height: 28,
            width: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.brSm),
            child: Text('${item.orderNumber}',
                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          const Text('Pembahasan', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const Spacer(),
          StatusBadge(label: badgeLabel, tone: badgeTone),
        ]),
        const SizedBox(height: 12),

        // Pertanyaan
        Text(plainText(item.question),
            style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        if (imageUrl != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.brMd,
            child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ],
        const SizedBox(height: 12),

        // Jawaban peserta
        _AnswerLine(
          label: 'Jawaban Kamu',
          value: item.dijawab ? '${item.selectedLabel}. ${plainText(item.selectedText ?? '')}' : 'Tidak dijawab',
          tone: !item.dijawab
              ? _LineTone.neutral
              : item.isCorrect == false
                  ? _LineTone.wrong
                  : item.isCorrect == true
                      ? _LineTone.correct
                      : _LineTone.neutral,
        ),
        if (item.jawabanBenar != null) ...[
          const SizedBox(height: 8),
          _AnswerLine(label: 'Kunci Jawaban', value: item.jawabanBenar!, tone: _LineTone.correct),
        ],

        // Pembahasan
        if ((item.pembahasan ?? '').trim().isNotEmpty) ...[
          const Divider(height: 24, color: AppColors.border),
          const Text('Penjelasan',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(plainText(item.pembahasan!),
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
        ],
      ]),
    );
  }
}

enum _LineTone { correct, wrong, neutral }

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({required this.label, required this.value, required this.tone});
  final String label;
  final String value;
  final _LineTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (tone) {
      _LineTone.correct => (AppColors.primary.withValues(alpha: 0.08), AppColors.primaryDark, Icons.check_circle_rounded),
      _LineTone.wrong => (AppColors.danger.withValues(alpha: 0.08), AppColors.danger, Icons.cancel_rounded),
      _LineTone.neutral => (const Color(0xFFF1F5F9), AppColors.textSecondary, Icons.remove_circle_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brMd),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11.5, color: fg, fontWeight: FontWeight.w600)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}
