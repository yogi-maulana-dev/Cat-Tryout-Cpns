import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../../../../models/exam.dart';
import '../../../../screens/exam_detail_screen.dart';
import '../../../../services/exam_service.dart';
import '../../../../state/auth_provider.dart';
import '../widgets/exam_tile.dart';

enum _ExamFilter { semua, reguler, premium, diTempat }

extension on _ExamFilter {
  String get label => switch (this) {
        _ExamFilter.semua => 'Semua',
        _ExamFilter.reguler => 'Reguler',
        _ExamFilter.premium => 'Premium',
        _ExamFilter.diTempat => 'Di Tempat',
      };

  bool matches(Exam e) => switch (this) {
        _ExamFilter.semua => true,
        _ExamFilter.reguler => !e.isPremium,
        _ExamFilter.premium => e.isPremium,
        _ExamFilter.diTempat => e.isOnsite,
      };
}

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key});

  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  final _service = ExamService();
  final _scroll = ScrollController();

  final List<Exam> _items = [];
  int _page = 1;
  bool _loading = false; // muat halaman pertama
  bool _loadingMore = false; // muat halaman berikutnya
  bool _hasMore = true;
  String? _error;

  String _search = '';
  _ExamFilter _filter = _ExamFilter.semua;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
      _items.clear();
    });
    try {
      final res = await _service.list(page: 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.items);
        _hasMore = res.hasMore;
        _page = 2;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final res = await _service.list(page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.items);
        _hasMore = res.hasMore;
        _page++;
      });
    } catch (_) {
      // diamkan; footer tetap menawarkan "Muat lagi"
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<Exam> get _visible {
    final q = _search.trim().toLowerCase();
    return _items.where((e) {
      final okSearch = q.isEmpty || e.namaSesi.toLowerCase().contains(q);
      return okSearch && _filter.matches(e);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final memberAktif = auth.user?.memberAktif ?? false;
    final isAdmin = auth.user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Tryout')),
      body: ContentWidth(child: Column(children: [
        // Pencarian
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Cari tryout…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        // Filter
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final f in _ExamFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.label),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: _filter == f ? AppColors.primaryDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(color: _filter == f ? AppColors.primary : AppColors.border),
                    backgroundColor: AppColors.surface,
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildBody(memberAktif, isAdmin)),
      ])),
    );
  }

  Widget _buildBody(bool memberAktif, bool isAdmin) {
    if (_loading) return const SkeletonList();
    if (_error != null && _items.isEmpty) {
      return ErrorStateView(message: 'Gagal memuat tryout.\n$_error', onRetry: _loadFirst);
    }

    final list = _visible;
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: list.isEmpty
          ? ListView(children: const [
              SizedBox(height: 80),
              EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Tidak ada tryout',
                message: 'Coba ubah kata kunci atau filter pencarian.',
              ),
            ])
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              // +1 header hitungan, +1 footer muat-lagi
              itemCount: list.length + 2,
              itemBuilder: (context, i) {
                if (i == 0) return _CountHeader(count: list.length, hasMore: _hasMore);
                if (i == list.length + 1) {
                  return _MoreFooter(hasMore: _hasMore, loading: _loadingMore, onTap: _loadMore);
                }
                final e = list[i - 1];
                final locked = e.isPremium && !memberAktif && !isAdmin;
                return ExamTile(
                  exam: e,
                  locked: locked,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExamDetailScreen(examId: e.id)),
                  ),
                );
              },
            ),
    );
  }
}

class _CountHeader extends StatelessWidget {
  const _CountHeader({required this.count, required this.hasMore});
  final int count;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        '$count tryout${hasMore ? '+' : ''} tersedia',
        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter({required this.hasMore, required this.loading, required this.onTap});
  final bool hasMore;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox(height: 8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: const Text('Muat lagi'),
              ),
      ),
    );
  }
}
