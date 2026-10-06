import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/ui/ui.dart';
import '../../../../models/exam.dart';
import '../../../../models/history_item.dart';
import '../../../../screens/attempt_screen.dart';
import '../../../../screens/exam_detail_screen.dart';
import '../../../../screens/history_screen.dart';
import '../../../../screens/packages_screen.dart';
import '../../../../screens/result_screen.dart';
import '../../../../services/exam_service.dart';
import '../../../../state/auth_provider.dart';
import '../widgets/exam_tile.dart';

/// Ringkasan data dashboard: tryout tersedia + riwayat (sudah dinilai server).
class _HomeData {
  const _HomeData({required this.exams, required this.history, required this.totalDikerjakan});
  final List<Exam> exams;
  final List<HistoryItem> history; // halaman terbaru (maks 15)
  final int totalDikerjakan; // total akurat dari paginator

  bool get hasHistory => history.isNotEmpty;

  /// Rata-rata skor dari aktivitas terbaru (nilai dihitung backend).
  int get rataRata =>
      history.isEmpty ? 0 : (history.map((h) => h.totalScore).reduce((a, b) => a + b) / history.length).round();

  int get skorTerbaik =>
      history.isEmpty ? 0 : history.map((h) => h.totalScore).reduce((a, b) => a > b ? a : b);

  int get jumlahLulus => history.where((h) => h.isPassed).length;

  /// Persentase kelulusan atas aktivitas terbaru.
  int get persenLulus => history.isEmpty ? 0 : (jumlahLulus / history.length * 100).round();

  HistoryItem? get terakhir => history.isEmpty ? null : history.first;

  /// Rekomendasi: tryout yang belum pernah dikerjakan.
  List<Exam> get rekomendasi {
    final dikerjakan = history.map((h) => h.examSessionId).toSet();
    final belum = exams.where((e) => !dikerjakan.contains(e.id)).toList();
    return (belum.isEmpty ? exams : belum);
  }
}

/// Beranda/Dashboard peserta. [onSelectTab] untuk pindah tab (mis. ke Tryout).
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onSelectTab});
  final ValueChanged<int> onSelectTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _service = ExamService();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final exams = await _service.list();
    // Riwayat opsional: peserta baru belum punya → jangan gagalkan dashboard.
    List<HistoryItem> history = const [];
    int total = 0;
    try {
      final h = await _service.history();
      history = h.items;
      total = h.total;
    } catch (_) {
      // abaikan; tampilkan dashboard tanpa statistik
    }
    return _HomeData(exams: exams.items, history: history, totalDikerjakan: total);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final memberAktif = user?.memberAktif ?? false;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final desktop = c.maxWidth >= 1024;
          return ContentWidth(
            maxWidth: desktop ? 1140 : 720,
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() => _future = _load());
                  await _future;
                },
                child: ListView(
                  padding: EdgeInsets.all(desktop ? 24 : 16),
                  children: [
                    _Greeting(name: user?.name, memberAktif: memberAktif),
                    const SizedBox(height: 20),
                    FutureBuilder<_HomeData>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _DashboardSkeleton();
                        }
                        if (snap.hasError) {
                          return ErrorStateView(
                            message: 'Gagal memuat beranda.\n${snap.error}',
                            onRetry: () => setState(() => _future = _load()),
                          );
                        }
                        final data = snap.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Prioritas: mulai tryout / lihat progres (bukan upgrade).
                            if (data.hasHistory) ...[
                              const SectionHeader(title: 'Statistik Kamu'),
                              const SizedBox(height: 8),
                              _StatsGrid(data: data, desktop: desktop),
                              const SizedBox(height: 12),
                              _LastResultCard(item: data.terakhir!),
                            ] else
                              _HeroStartCard(wide: desktop, onStart: () => widget.onSelectTab(1)),
                            const SizedBox(height: 24),

                            _QuickMenuRow(onSelectTab: widget.onSelectTab, desktop: desktop),
                            const SizedBox(height: 24),

                            SectionHeader(
                              title: data.hasHistory ? 'Rekomendasi Untukmu' : 'Tryout Tersedia',
                              actionLabel: 'Lihat semua',
                              onAction: () => widget.onSelectTab(1),
                            ),
                            const SizedBox(height: 8),
                            _RecommendationList(exams: data.rekomendasi, memberAktif: memberAktif, desktop: desktop),

                            // Upgrade = promosi sekunder, diletakkan di bawah.
                            if (!memberAktif) ...[
                              const SizedBox(height: 24),
                              _UpgradeBanner(
                                onTap: () => Navigator.push(
                                    context, MaterialPageRoute(builder: (_) => const PackagesScreen())),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Greeting

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.memberAktif});
  final String? name;
  final bool memberAktif;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          (name?.isNotEmpty ?? false) ? name![0].toUpperCase() : 'U',
          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Selamat datang,', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(name ?? 'Peserta',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ]),
      ),
      StatusBadge(
        label: memberAktif ? 'Member' : 'Gratis',
        tone: memberAktif ? BadgeTone.success : BadgeTone.neutral,
        icon: memberAktif ? Icons.workspace_premium_rounded : null,
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────── Statistik

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data, required this.desktop});
  final _HomeData data;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final lulusColor = data.persenLulus >= 50 ? AppColors.success : AppColors.warning;
    final cards = <Widget>[
      StatCard(icon: Icons.assignment_turned_in_rounded, value: '${data.totalDikerjakan}', label: 'Tryout Dikerjakan'),
      StatCard(icon: Icons.trending_up_rounded, value: '${data.rataRata}', label: 'Rata-rata Skor', color: AppColors.info),
      StatCard(icon: Icons.emoji_events_rounded, value: '${data.skorTerbaik}', label: 'Skor Terbaik', color: AppColors.warning),
      StatCard(icon: Icons.verified_rounded, value: '${data.persenLulus}%', label: 'Kelulusan', color: lulusColor),
    ];

    if (desktop) {
      // 4 kolom sejajar — memanfaatkan ruang horizontal.
      return Row(children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ]);
    }
    // Mobile/tablet: 2×2.
    return Column(children: [
      Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
    ]);
  }
}

class _LastResultCard extends StatelessWidget {
  const _LastResultCard({required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final ongoing = item.isOngoing;
    return AppCard(
      // Attempt yang belum selesai → lanjutkan pengerjaan; selesai → lihat hasil.
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
            color: (ongoing
                    ? AppColors.info
                    : (item.isPassed ? AppColors.primary : AppColors.warning))
                .withValues(alpha: 0.12),
            borderRadius: AppRadius.brMd,
          ),
          child: Icon(
              ongoing
                  ? Icons.timelapse_rounded
                  : (item.isPassed ? Icons.workspace_premium_rounded : Icons.history_rounded),
              color: ongoing ? AppColors.info : (item.isPassed ? AppColors.primary : AppColors.warning)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ongoing ? 'Sedang Berjalan' : 'Hasil Terakhir',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(item.namaSesi ?? 'Tryout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (!ongoing && item.finishedAt != null)
              Text(DateFormat('d MMM yyyy, HH:mm').format(item.finishedAt!.toLocal()),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(width: 8),
        ongoing
            ? const StatusBadge(label: 'Lanjutkan', tone: BadgeTone.info, icon: Icons.play_arrow_rounded)
            : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${item.totalScore}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                StatusBadge(
                  label: item.isPassed ? 'Lulus' : 'Belum',
                  tone: item.isPassed ? BadgeTone.success : BadgeTone.warning,
                ),
              ]),
      ]),
    );
  }
}

/// CTA utama untuk peserta yang belum punya riwayat (prioritas di dashboard).
class _HeroStartCard extends StatelessWidget {
  const _HeroStartCard({required this.wide, required this.onStart});
  final bool wide;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      height: 52,
      width: 52,
      decoration: const BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.brMd),
      child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 26),
    );
    const title = Text('Mulai Tryout Pertamamu',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
    const subtitle = Text('Kerjakan tryout untuk melihat statistik & progres belajarmu di sini.',
        style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4));
    final button = PrimaryButton(
      label: 'Mulai Sekarang',
      icon: Icons.arrow_forward_rounded,
      expand: !wide,
      onPressed: onStart,
    );

    return AppCard(
      highlighted: true,
      padding: const EdgeInsets.all(20),
      child: wide
          ? Row(children: [
              icon,
              const SizedBox(width: 16),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  title,
                  SizedBox(height: 4),
                  subtitle,
                ]),
              ),
              const SizedBox(width: 16),
              button,
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [icon, const SizedBox(width: 12), const Expanded(child: title)]),
              const SizedBox(height: 10),
              subtitle,
              const SizedBox(height: 16),
              button,
            ]),
    );
  }
}

// ─────────────────────────────────────────────────────────── Menu cepat

class _QuickMenuRow extends StatelessWidget {
  const _QuickMenuRow({required this.onSelectTab, required this.desktop});
  final ValueChanged<int> onSelectTab;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final row = Row(children: [
      _QuickMenu(icon: Icons.assignment_rounded, label: 'Tryout', onTap: () => onSelectTab(1)),
      const SizedBox(width: 12),
      _QuickMenu(icon: Icons.leaderboard_rounded, label: 'Ranking', onTap: () => onSelectTab(2)),
      const SizedBox(width: 12),
      _QuickMenu(
          icon: Icons.history_rounded,
          label: 'Riwayat',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
      const SizedBox(width: 12),
      _QuickMenu(
          icon: Icons.workspace_premium_rounded,
          label: 'Paket',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackagesScreen()))),
    ]);
    // Desktop: jangan melebar penuh seperti HP — batasi & rata kiri.
    if (desktop) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: row),
      );
    }
    return row;
  }
}

// ─────────────────────────────────────────────────────────── Rekomendasi

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({required this.exams, required this.memberAktif, required this.desktop});
  final List<Exam> exams;
  final bool memberAktif;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final list = exams.take(desktop ? 6 : 3).toList();
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Belum ada tryout',
        message: 'Nantikan tryout berikutnya.',
      );
    }
    Widget tile(Exam e) => ExamTile(
          exam: e,
          locked: e.isPremium && !memberAktif,
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ExamDetailScreen(examId: e.id))),
        );

    if (!desktop) {
      return Column(children: [for (final e in list) tile(e)]);
    }
    // Desktop: grid 2 kolom.
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - 16) / 2;
      return Wrap(
        spacing: 16,
        runSpacing: 0,
        children: [for (final e in list) SizedBox(width: w, child: tile(e))],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────── Potongan UI

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.brLg,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(gradient: AppColors.ctaGradient, borderRadius: AppRadius.brLg),
        child: const Row(children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Upgrade ke Member',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              SizedBox(height: 2),
              Text('Buka semua tryout premium & pembahasan',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white),
        ]),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: AppRadius.brMd,
        onTap: onTap,
        child: Column(children: [
          Container(
            height: 52,
            width: 52,
            decoration: const BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.brMd),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: SkeletonBox(height: 96, radius: 16)),
        SizedBox(width: 12),
        Expanded(child: SkeletonBox(height: 96, radius: 16)),
      ]),
      SizedBox(height: 12),
      SkeletonBox(height: 76, radius: 16),
      SizedBox(height: 20),
      SkeletonBox(height: 72, radius: 16),
      SizedBox(height: 12),
      SkeletonBox(height: 72, radius: 16),
    ]);
  }
}
