import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../../../models/exam.dart';
import '../../../../screens/ranking_screen.dart';
import '../../../../services/exam_service.dart';
import '../widgets/exam_tile.dart';

class RankingTab extends StatefulWidget {
  const RankingTab({super.key});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> {
  final _service = ExamService();
  late Future<List<Exam>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Exam>> _load() async => (await _service.list()).items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: ContentWidth(child: RefreshIndicator(
        onRefresh: () async => setState(() => _future = _load()),
        child: FutureBuilder<List<Exam>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SkeletonList();
            }
            if (snap.hasError) {
              return ErrorStateView(message: '${snap.error}', onRetry: () => setState(() => _future = _load()));
            }
            final exams = snap.data ?? [];
            if (exams.isEmpty) {
              return const EmptyState(
                icon: Icons.leaderboard_outlined,
                title: 'Belum ada ranking',
                message: 'Ranking akan tersedia setelah ada tryout.',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text('Pilih tryout untuk melihat papan peringkat.',
                    style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                for (final e in exams)
                  ExamTile(
                    exam: e,
                    trailingLabel: 'Ranking',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RankingScreen(examId: e.id, examTitle: e.namaSesi)),
                    ),
                  ),
              ],
            );
          },
        ),
      )),
    );
  }
}
