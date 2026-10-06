import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../models/attempt_score.dart';
import '../services/attempt_service.dart';
import 'ranking_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  final String attemptId;
  const ResultScreen({super.key, required this.attemptId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _service = AttemptService();
  late Future<ResultBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.result(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Tryout'),
        automaticallyImplyLeading: false,
      ),
      body: ContentWidth(child: FutureBuilder<ResultBundle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Menghitung hasil…');
          }
          if (snap.hasError) {
            return ErrorStateView(
              message: '${snap.error}',
              onRetry: () => setState(() => _future = _service.result(widget.attemptId)),
            );
          }
          final r = snap.data!;
          final passed = r.attempt.isPassed;
          final benar = r.scores.fold<int>(0, (a, s) => a + s.correctCount);
          final salah = r.scores.fold<int>(0, (a, s) => a + s.wrongCount);
          final kosong = r.scores.fold<int>(0, (a, s) => a + s.unansweredCount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeroResult(passed: passed, totalScore: r.attempt.totalScore),
              const SizedBox(height: 16),

              // Ringkasan benar/salah/kosong
              Row(children: [
                Expanded(child: StatCard(icon: Icons.check_circle_rounded, value: '$benar', label: 'Benar')),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.cancel_rounded, value: '$salah', label: 'Salah', color: AppColors.danger)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.remove_circle_outline_rounded, value: '$kosong', label: 'Kosong', color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 20),

              const SectionHeader(title: 'Rincian per Kategori'),
              const SizedBox(height: 8),
              for (final s in r.scores) _CategoryCard(score: s),

              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Lihat Pembahasan',
                icon: Icons.menu_book_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewScreen(attemptId: r.attempt.id)),
                ),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Lihat Ranking',
                icon: Icons.leaderboard_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RankingScreen(examId: r.attempt.examSessionId)),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          );
        },
      )),
    );
  }
}

class _HeroResult extends StatelessWidget {
  const _HeroResult({required this.passed, required this.totalScore});
  final bool passed;
  final int totalScore;

  @override
  Widget build(BuildContext context) {
    final gradient = passed
        ? AppColors.ctaGradient
        : const LinearGradient(colors: [Color(0xFF64748B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(gradient: gradient, borderRadius: AppRadius.brXl),
      child: Column(children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
          child: Icon(passed ? Icons.emoji_events_rounded : Icons.flag_circle_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 14),
        Text('$totalScore',
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1.0)),
        const SizedBox(height: 2),
        const Text('Total Skor', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: AppRadius.brPill),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(passed ? Icons.check_circle_rounded : Icons.info_rounded,
                size: 16, color: passed ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(passed ? 'LULUS' : 'BELUM LULUS',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                    color: passed ? AppColors.primaryDark : AppColors.textPrimary)),
          ]),
        ),
      ]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.score});
  final AttemptScore score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ScoreBar(
          label: score.tipe ?? 'Tipe ${score.tipeSoalId}',
          score: score.score,
          max: score.maxScore,
          passingGrade: score.passingGrade,
        ),
        Row(children: [
          _MiniStat(icon: Icons.check_rounded, value: score.correctCount, color: AppColors.primary),
          const SizedBox(width: 14),
          _MiniStat(icon: Icons.close_rounded, value: score.wrongCount, color: AppColors.danger),
          const SizedBox(width: 14),
          _MiniStat(icon: Icons.remove_rounded, value: score.unansweredCount, color: AppColors.textSecondary),
          const Spacer(),
          StatusBadge(
            label: score.isPassed ? 'Lulus' : 'Belum',
            tone: score.isPassed ? BadgeTone.success : BadgeTone.warning,
          ),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.color});
  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text('$value', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
    ]);
  }
}
