import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../models/history_item.dart';
import '../services/exam_service.dart';
import 'attempt_screen.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _examService = ExamService();
  final _scroll = ScrollController();
  final List<HistoryItem> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (!reset && !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _hasMore = true;
        _items.clear();
      }
    });
    try {
      final res = await _examService.history(page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.items);
        _hasMore = res.hasMore;
        _page++;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengerjaan')),
      body: ContentWidth(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) return const SkeletonList();
    if (_error != null && _items.isEmpty) {
      return ErrorStateView(message: 'Gagal memuat riwayat.\n$_error', onRetry: () => _load(reset: true));
    }
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'Belum ada riwayat',
        message: 'Riwayat pengerjaan tryout kamu akan muncul di sini.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + 1,
        itemBuilder: (context, i) {
          if (i == _items.length) {
            return _hasMore
                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
                : const SizedBox(height: 8);
          }
          return _HistoryTile(item: _items[i]);
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final passed = item.isPassed;
    final ongoing = item.isOngoing;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      // Attempt yang belum selesai → lanjutkan; selesai → lihat hasil.
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ongoing
              ? AttemptScreen(attemptId: item.attemptId)
              : ResultScreen(attemptId: item.attemptId),
        ),
      ),
      child: Row(children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: (ongoing ? AppColors.info : (passed ? AppColors.primary : AppColors.warning))
                .withValues(alpha: 0.12),
            borderRadius: AppRadius.brMd,
          ),
          child: Icon(
              ongoing
                  ? Icons.timelapse_rounded
                  : (passed ? Icons.workspace_premium_rounded : Icons.assignment_turned_in_rounded),
              color: ongoing ? AppColors.info : (passed ? AppColors.primary : AppColors.warning)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.namaSesi ?? 'Tryout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              'Percobaan ke-${item.attemptNumber}'
              '${!ongoing && item.finishedAt != null ? ' • ${DateFormat('d MMM yyyy, HH:mm').format(item.finishedAt!.toLocal())}' : ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        ongoing
            ? const StatusBadge(label: 'Lanjutkan', tone: BadgeTone.info, icon: Icons.play_arrow_rounded)
            : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${item.totalScore}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                StatusBadge(
                  label: passed ? 'Lulus' : 'Belum',
                  tone: passed ? BadgeTone.success : BadgeTone.warning,
                ),
              ]),
      ]),
    );
  }
}
