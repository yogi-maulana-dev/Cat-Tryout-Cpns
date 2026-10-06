import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../models/exam.dart';
import '../services/attempt_service.dart';
import '../services/exam_service.dart';
import '../state/auth_provider.dart';
import 'attempt_screen.dart';
import 'packages_screen.dart';
import 'ranking_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  final _examService = ExamService();
  final _attemptService = AttemptService();

  Exam? _exam;
  bool _loading = true;
  String? _error;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final e = await _examService.detail(widget.examId);
      if (!mounted) return;
      setState(() => _exam = e);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start(Exam exam) async {
    String? token;
    if (exam.requiresToken) {
      token = await _askToken();
      if (token == null || token.isEmpty) return; // peserta batal
    }
    setState(() => _starting = true);
    try {
      final attempt = await _attemptService.start(widget.examId, token: token);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AttemptScreen(attemptId: attempt.id)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.needsUpgrade) {
        _showUpgradePrompt(e.firstError); // kuota habis / khusus member → tawarkan upgrade
      } else {
        _snack(e.firstError);
      }
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Dialog ajakan berlangganan saat akses tryout dibatasi (gratis 1x, premium, dll).
  void _showUpgradePrompt(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.workspace_premium_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(child: Text('Jadi Member')),
        ]),
        content: Text(
          '$reason\n\nUpgrade ke member untuk mengerjakan lebih banyak tryout, '
          'buka tryout premium, dan akses pembahasan lengkap.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nanti')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _goUpgrade();
            },
            icon: const Icon(Icons.workspace_premium_rounded, size: 18),
            label: const Text('Lihat Paket'),
          ),
        ],
      ),
    );
  }

  /// Dialog input token untuk ujian di tempat. Null = batal.
  Future<String?> _askToken() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan Token Ujian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Token diumumkan oleh pengawas/proktor saat ujian dimulai.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            AppTextField(
              controller: ctrl,
              label: 'Token',
              hint: 'Mis. ABC123',
              prefixIcon: Icons.vpn_key_rounded,
              capitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Mulai')),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goUpgrade() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PackagesScreen()));

  @override
  Widget build(BuildContext context) {
    final memberAktif = context.watch<AuthProvider>().user?.memberAktif ?? false;
    final e = _exam;
    final locked = e != null && e.isPremium && !memberAktif;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tryout'),
        actions: [
          IconButton(
            tooltip: 'Ranking',
            icon: const Icon(Icons.leaderboard_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RankingScreen(examId: widget.examId)),
            ),
          ),
        ],
      ),
      body: ContentWidth(
        // Desktop/laptop: kontainer lebih lega namun tetap terpusat.
        maxWidth: MediaQuery.sizeOf(context).width >= 1024 ? 980 : 720,
        child: _loading
            ? const LoadingState(message: 'Memuat detail tryout…')
            : _error != null
                ? ErrorStateView(message: _error!, onRetry: _load)
                : _Content(exam: e!, locked: locked),
      ),
      bottomNavigationBar: e == null ? null : _BottomCta(
        exam: e,
        locked: locked,
        starting: _starting,
        onStart: () => _start(e),
        onUpgrade: _goUpgrade,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Konten

class _Content extends StatelessWidget {
  const _Content({required this.exam, required this.locked});
  final Exam exam;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        AppCard(
          child: Row(children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: locked ? AppColors.warning.withValues(alpha: 0.14) : AppColors.primaryLight,
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(locked ? Icons.lock_rounded : Icons.assignment_rounded,
                  color: locked ? AppColors.warning : AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(exam.namaSesi,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                if (exam.nomorSesi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Sesi ${exam.nomorSesi}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ]),
            ),
          ]),
        ),

        // Badges
        if (exam.isPremium || exam.isOnsite || exam.requiresToken) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (exam.isPremium)
              const StatusBadge(label: 'Premium', tone: BadgeTone.premium, icon: Icons.workspace_premium_rounded),
            if (exam.isOnsite)
              const StatusBadge(label: 'Ujian di Tempat', tone: BadgeTone.info, icon: Icons.location_on_rounded),
            if (exam.requiresToken)
              const StatusBadge(label: 'Perlu Token', tone: BadgeTone.warning, icon: Icons.vpn_key_rounded),
          ]),
        ],

        // Banner premium terkunci
        if (locked) ...[
          const SizedBox(height: 12),
          _LockedBanner(),
        ],

        // Statistik tryout (grid responsif: 2 kolom, 1 kolom di HP sangat sempit)
        const SizedBox(height: 16),
        _InfoGrid(exam: exam),

        // Jadwal berakhir
        if (exam.tanggalBerakhir != null) ...[
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              const Icon(Icons.event_busy_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              const Text('Berakhir', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              Text(DateFormat('d MMM yyyy, HH:mm').format(exam.tanggalBerakhir!.toLocal()),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
            ]),
          ),
        ],

        // Keterangan
        if ((exam.keterangan ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionHeader(title: 'Keterangan'),
          const SizedBox(height: 8),
          AppCard(child: Text(exam.keterangan!, style: const TextStyle(color: AppColors.textPrimary, height: 1.45))),
        ],

        // Komposisi soal
        if (exam.komposisi.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionHeader(title: 'Komposisi Soal'),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < exam.komposisi.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.border),
                  _KomposisiRow(item: exam.komposisi[i]),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

/// Grid info tryout yang responsif: 2 kolom (desktop/tablet/HP normal),
/// otomatis jadi 1 kolom pada layar sangat sempit. Data dari model [Exam].
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      StatCard(icon: Icons.schedule_rounded, value: '${exam.durasiMenit}', label: 'Menit', color: AppColors.info),
      StatCard(icon: Icons.help_outline_rounded, value: '${exam.totalSoal}', label: 'Total Soal'),
      StatCard(
        icon: Icons.sort_rounded,
        value: exam.urutanSoal == 'acak' ? 'Acak' : 'Urut',
        label: 'Urutan Soal',
        color: AppColors.textSecondary,
      ),
      StatCard(
        icon: Icons.replay_rounded,
        value: exam.maxAttempt != null ? '${exam.maxAttempt}x' : '∞',
        label: 'Kesempatan',
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      const gap = 12.0;
      final cols = c.maxWidth < 360 ? 1 : 2;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final card in cards) SizedBox(width: w, child: card)],
      );
    });
  }
}

class _KomposisiRow extends StatelessWidget {
  const _KomposisiRow({required this.item});
  final KomposisiItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          child: Text(item.tipe ?? 'Tipe ${item.tipeSoalId}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        Text('${item.jumlahSoal} soal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        if (item.passingGrade != null) ...[
          const SizedBox(width: 10),
          StatusBadge(label: 'PG ${item.passingGrade}', tone: BadgeTone.neutral),
        ],
      ]),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(children: [
        Icon(Icons.lock_rounded, color: AppColors.warning),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Tryout ini khusus member. Berlangganan paket untuk membukanya.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.35),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────────────────────────────────────── CTA bawah

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.exam,
    required this.locked,
    required this.starting,
    required this.onStart,
    required this.onUpgrade,
  });

  final Exam exam;
  final bool locked;
  final bool starting;
  final VoidCallback onStart;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1024;

    // Desktop: tombol tidak melebar penuh (expand:false) → rata kanan; mobile: full-width.
    final button = locked
        ? PrimaryButton(
            label: 'Upgrade Member untuk Membuka',
            icon: Icons.workspace_premium_rounded,
            expand: !desktop,
            onPressed: onUpgrade,
          )
        : PrimaryButton(
            label: exam.requiresToken ? 'Masukkan Token & Mulai' : 'Mulai Tryout',
            icon: exam.requiresToken ? Icons.vpn_key_rounded : Icons.play_arrow_rounded,
            loading: starting,
            expand: !desktop,
            onPressed: onStart,
          );

    // Footer bar: punya background + border atas, konten dibatasi lebar & terpusat
    // (selaras dengan kontainer konten), jadi tidak melebar aneh di laptop.
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(vertical: 10),
        child: ContentWidth(
          maxWidth: desktop ? 980 : 720,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: desktop
                ? Center(
                    // Lebar minimal 260 (melebar bila label panjang) biar mantap.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 260),
                      child: button,
                    ),
                  )
                : button,
          ),
        ),
      ),
    );
  }
}
