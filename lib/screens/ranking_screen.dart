import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../services/exam_service.dart';
import '../state/auth_provider.dart';

class RankingScreen extends StatefulWidget {
  final String examId;
  final String? examTitle;
  const RankingScreen({super.key, required this.examId, this.examTitle});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _examService = ExamService();
  late Future<RankingResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _examService.ranking(widget.examId);
  }

  Future<void> _refresh() async {
    setState(() => _future = _examService.ranking(widget.examId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id;
    return Scaffold(
      appBar: AppBar(title: Text(widget.examTitle ?? 'Ranking')),
      body: ContentWidth(child: FutureBuilder<RankingResult>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Memuat papan peringkat…');
          }
          if (snap.hasError) {
            return ErrorStateView(message: '${snap.error}', onRetry: _refresh);
          }
          final r = snap.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MyStatsCard(rank: r.myRank, bestScore: r.myBestScore, totalPeserta: r.totalPeserta),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Papan Peringkat'),
                const SizedBox(height: 8),
                if (r.ranking.isEmpty)
                  const EmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: 'Belum ada peserta',
                    message: 'Jadilah yang pertama menyelesaikan tryout ini.',
                  )
                else
                  // Posisi dari urutan list (sudah diurutkan server by best_score);
                  // field `rank` dari API tidak dipakai karena belum terisi benar.
                  for (final (i, e) in r.ranking.indexed)
                    _RankRow(position: i + 1, entry: e, isMe: myId != null && e.userId == myId),
              ],
            ),
          );
        },
      )),
    );
  }
}

class _MyStatsCard extends StatelessWidget {
  const _MyStatsCard({required this.rank, required this.bestScore, required this.totalPeserta});
  final int? rank;
  final int bestScore;
  final int totalPeserta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(gradient: AppColors.ctaGradient, borderRadius: AppRadius.brXl),
      child: Row(children: [
        Expanded(child: _stat('Peringkat', rank != null ? '#$rank' : '-')),
        _divider(),
        Expanded(child: _stat('Skor Terbaik', '$bestScore')),
        _divider(),
        Expanded(child: _stat('Peserta', '$totalPeserta')),
      ]),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.25));

  Widget _stat(String label, String value) => Column(children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]);
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.position, required this.entry, required this.isMe});
  final int position;
  final RankingEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, medal) = switch (position) {
      1 => (const Color(0xFFF59E0B), Colors.white, true),
      2 => (const Color(0xFF94A3B8), Colors.white, true),
      3 => (const Color(0xFFB45309), Colors.white, true),
      _ => (AppColors.primaryLight, AppColors.primaryDark, false),
    };
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      highlighted: isMe,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          height: 36,
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: badgeBg, borderRadius: AppRadius.brMd),
          child: medal
              ? Icon(Icons.emoji_events_rounded, size: 18, color: badgeFg)
              : Text('$position', style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            Flexible(
              child: Text(entry.name ?? 'Peserta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              const StatusBadge(label: 'Kamu', tone: BadgeTone.success),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        Text('${entry.bestScore}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
      ]),
    );
  }
}
