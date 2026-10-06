import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/content_format.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/ui/ui.dart';
import '../models/attempt.dart';
import '../models/attempt_question.dart';
import '../services/attempt_service.dart';
import 'result_screen.dart';

class AttemptScreen extends StatefulWidget {
  final String attemptId;
  const AttemptScreen({super.key, required this.attemptId});

  @override
  State<AttemptScreen> createState() => _AttemptScreenState();
}

class _AttemptScreenState extends State<AttemptScreen> {
  final _service = AttemptService();

  Attempt? _attempt;
  List<AttemptQuestion> _questions = [];
  final Set<int> _flagged = {}; // id soal yang ditandai ragu-ragu (lokal, bantuan UI)
  int _index = 0;
  bool _loading = true;
  bool _submitting = false;
  bool _timeUpHandled = false; // cegah dialog waktu-habis muncul ganda
  String? _error;
  SaveStatus _saveStatus = SaveStatus.saved;

  Timer? _timer;
  Timer? _heartbeatTimer;
  Duration _remaining = Duration.zero;

  static const _lowTimeThreshold = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────── Data & timer

  Future<void> _load() async {
    try {
      final attempt = await _service.show(widget.attemptId);
      final questions = await _service.questions(widget.attemptId);
      if (!mounted) return;
      setState(() {
        _attempt = attempt;
        _questions = questions;
        _loading = false;
      });
      _startTimer();
      _startHeartbeat();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.firstError;
          _loading = false;
        });
      }
    }
  }

  void _startTimer() {
    final ends = _attempt?.expiresAt;
    if (ends == null) return;
    _tick(ends);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(ends));
  }

  void _tick(DateTime ends) {
    final rem = ends.difference(DateTime.now());
    if (rem.isNegative || rem.inSeconds <= 0) {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      _onTimeUp(); // tampilkan pesan lalu submit otomatis (server tetap otoritatif)
      return;
    }
    setState(() => _remaining = rem);
  }

  /// Heartbeat berkala: lapor presence+progress, sinkron sisa waktu (server =
  /// source of truth), dan tangkap attempt yang sudah diakhiri server.
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) => _sendHeartbeat());
  }

  Future<void> _sendHeartbeat() async {
    try {
      final hb = await _service.heartbeat(widget.attemptId, current: _index + 1);
      if (!hb.isOngoing) {
        _heartbeatTimer?.cancel();
        _timer?.cancel();
        _goResult();
        return;
      }
      if (hb.remainingSeconds != null) {
        final serverEnds = DateTime.now().add(Duration(seconds: hb.remainingSeconds!));
        _timer?.cancel();
        _tick(serverEnds);
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(serverEnds));
      }
    } catch (_) {
      // Gagal jaringan → abaikan; dicoba lagi pada interval berikutnya.
    }
  }

  // ───────────────────────────────────────────────────── Aksi peserta

  Future<void> _saveCurrent(int? optionId) async {
    final q = _questions[_index];
    setState(() {
      q.selectedOptionId = optionId;
      _saveStatus = SaveStatus.saving;
    });
    try {
      await _service.saveAnswer(widget.attemptId, q.id, optionId);
      if (mounted) setState(() => _saveStatus = SaveStatus.saved);
    } on ApiException catch (e) {
      if (e.isConflict || e.statusCode == 422) {
        _goResult(); // attempt tak lagi aktif / waktu habis → ke hasil
      } else {
        if (mounted) setState(() => _saveStatus = SaveStatus.offline);
        _snack(e.firstError);
      }
    } catch (_) {
      if (mounted) setState(() => _saveStatus = SaveStatus.offline);
    }
  }

  void _toggleFlag() {
    final id = _questions[_index].id;
    setState(() => _flagged.contains(id) ? _flagged.remove(id) : _flagged.add(id));
  }

  void _goTo(int i) {
    if (i < 0 || i >= _questions.length) return;
    setState(() => _index = i);
  }

  /// Waktu habis: beri pesan jelas dulu, lalu submit otomatis.
  Future<void> _onTimeUp() async {
    if (_timeUpHandled) return;
    _timeUpHandled = true;
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    if (mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.timer_off_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Waktu Habis'),
          ]),
          content: const Text(
            'Waktu pengerjaan telah selesai. Jawabanmu otomatis dikumpulkan dan dinilai.',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lihat Hasil')),
          ],
        ),
      );
    }
    await _submit(auto: true);
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    if (!auto) {
      final unanswered = _questions.length - _answeredCount();
      final yakin = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Selesaikan tryout?'),
          content: Text(
            'Terjawab ${_answeredCount()}/${_questions.length} soal'
            '${unanswered > 0 ? ' — masih ada $unanswered soal kosong' : ''}.\n'
            'Jawaban tidak bisa diubah setelah selesai.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Selesai')),
          ],
        ),
      );
      if (yakin != true) return;
    }
    setState(() => _submitting = true);
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    try {
      await _service.finish(widget.attemptId);
      _goResult();
    } on ApiException catch (e) {
      if (e.isConflict) {
        _goResult(); // sudah selesai/expired di server
      } else {
        _snack(e.firstError);
        if (mounted) setState(() => _submitting = false);
      }
    }
  }

  void _goResult() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(attemptId: widget.attemptId)),
    );
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar dari ujian?'),
        content: const Text(
          'Jawabanmu tersimpan otomatis dan waktu tetap berjalan. '
          'Kamu bisa melanjutkan attempt ini nanti.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Lanjut Ujian')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  // ───────────────────────────────────────────────────── Navigator sheet

  void _openNavigator() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _NavigatorPanel(
            questions: _questions,
            flagged: _flagged,
            currentIndex: _index,
            answered: _answeredCount(),
            scrollController: scrollCtrl,
            onJump: (i) {
              Navigator.pop(context);
              _goTo(i);
            },
            onFinish: () {
              Navigator.pop(context);
              _submit();
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────── Helpers

  int _answeredCount() => _questions.where((q) => q.isAnswered).length;

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  /// Area soal + opsi jawaban, dibatasi lebar baca & dipusatkan ([maxWidth]
  /// lebih lebar di desktop). Dipakai pada layout mobile maupun 2-kolom.
  Widget _questionArea(AttemptQuestion q, bool flagged, {required double maxWidth}) {
    return ContentWidth(
      maxWidth: maxWidth,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Header soal + tombol tandai
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.brPill),
              child: Text('Soal ${_index + 1}',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
            const Spacer(),
            _FlagButton(flagged: flagged, onTap: _toggleFlag),
          ]),
          const SizedBox(height: 14),
          // Pertanyaan
          Text(plainText(q.question),
              style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          if (resolveImageUrl(q.questionImage) != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: AppRadius.brMd,
              child: Image.network(resolveImageUrl(q.questionImage)!,
                  fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          ],
          const SizedBox(height: 20),
          // Opsi jawaban
          for (final o in q.options)
            AnswerOption(
              label: o.optionLabel,
              text: plainText(o.optionText),
              imageUrl: resolveImageUrl(o.gambarJawaban),
              selected: q.selectedOptionId == o.id,
              onTap: () => _saveCurrent(o.id),
            ),
          if (q.isAnswered)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _saveCurrent(null),
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Kosongkan jawaban'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────── Build

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingState(message: 'Menyiapkan soal…'));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(message: _error!, onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _load();
        }),
      );
    }

    final q = _questions[_index];
    final flagged = _flagged.contains(q.id);
    final lowTime = _attempt?.expiresAt != null && _remaining <= _lowTimeThreshold;
    final isLast = _index == _questions.length - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final leave = await _confirmLeave();
        if (!mounted) return;
        if (leave) nav.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Soal ${_index + 1}/${_questions.length}'),
          actions: [
            Center(child: _TimerPill(label: _attempt?.expiresAt != null ? _fmt(_remaining) : '—', low: lowTime)),
            const SizedBox(width: 12),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 992; // laptop/desktop → 2 kolom + sidebar kanan
            return Column(children: [
              _ProgressStrip(
                answered: _answeredCount(),
                total: _questions.length,
                saveStatus: _saveStatus,
              ),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _questionArea(q, flagged, maxWidth: 960)),
                          _DesktopSidebar(
                            width: c.maxWidth >= 1200 ? 320 : 272,
                            questions: _questions,
                            flagged: _flagged,
                            currentIndex: _index,
                            answered: _answeredCount(),
                            onJump: _goTo,
                            onFinish: () => _submit(),
                          ),
                        ],
                      )
                    : _questionArea(q, flagged, maxWidth: 760),
              ),
              wide
                  ? _DesktopFooter(
                      canPrev: _index > 0,
                      isLast: isLast,
                      submitting: _submitting,
                      flagged: flagged,
                      onPrev: () => _goTo(_index - 1),
                      onNext: () => _goTo(_index + 1),
                      onToggleFlag: _toggleFlag,
                      onFinish: () => _submit(),
                    )
                  : _BottomBar(
                      canPrev: _index > 0,
                      isLast: isLast,
                      submitting: _submitting,
                      onPrev: () => _goTo(_index - 1),
                      onNext: () => _goTo(_index + 1),
                      onNavigator: _openNavigator,
                      onFinish: () => _submit(),
                    ),
            ]);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Potongan UI

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.label, required this.low});
  final String label;
  final bool low;

  @override
  Widget build(BuildContext context) {
    final color = low ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadius.brPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(low ? Icons.timelapse_rounded : Icons.timer_outlined, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
      ]),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.answered, required this.total, required this.saveStatus});
  final int answered;
  final int total;
  final SaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : answered / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        Row(children: [
          Text('Terjawab $answered/$total',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          ConnectionBadge(status: saveStatus),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadius.brPill,
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ]),
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({required this.flagged, required this.onTap});
  final bool flagged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = flagged ? AppColors.warning : AppColors.textSecondary;
    return InkWell(
      borderRadius: AppRadius.brPill,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: flagged ? AppColors.warning.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: flagged ? AppColors.warning : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(flagged ? Icons.flag_rounded : Icons.flag_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(flagged ? 'Ditandai' : 'Tandai',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ]),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(spacing: 16, runSpacing: 8, children: [
      _LegendItem(color: AppColors.answered, label: 'Terjawab'),
      _LegendItem(color: Color(0xFFF1F5F9), label: 'Kosong', dark: true),
      _LegendItem(color: AppColors.flagged, label: 'Ditandai'),
    ]);
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, this.dark = false});
  final Color color;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.brSm,
          border: dark ? Border.all(color: AppColors.border) : null,
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
    ]);
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.canPrev,
    required this.isLast,
    required this.submitting,
    required this.onPrev,
    required this.onNext,
    required this.onNavigator,
    required this.onFinish,
  });

  final bool canPrev;
  final bool isLast;
  final bool submitting;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNavigator;
  final VoidCallback onFinish;

  static const double _h = 52; // tinggi tombol nyaman di semua layar

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            // HP sempit → tombol "Sebelumnya" ringkas (ikon saja) agar muat.
            final compact = c.maxWidth < 380;
            return Row(children: [
              _prevButton(compact),
              const SizedBox(width: 8),
              Expanded(child: _navButton()),
              const SizedBox(width: 8),
              _primaryButton(compact),
            ]);
          },
        ),
      ),
    );
  }

  Widget _prevButton(bool compact) {
    final style = OutlinedButton.styleFrom(
      minimumSize: Size(compact ? _h : 0, _h),
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
    final onTap = canPrev ? onPrev : null;
    if (compact) {
      return OutlinedButton(onPressed: onTap, style: style, child: const Icon(Icons.chevron_left_rounded, size: 22));
    }
    return OutlinedButton(
      onPressed: onTap,
      style: style,
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.chevron_left_rounded, size: 20),
        SizedBox(width: 4),
        Text('Sebelumnya'),
      ]),
    );
  }

  Widget _navButton() {
    return OutlinedButton(
      onPressed: onNavigator,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, _h),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.grid_view_rounded, size: 18),
        SizedBox(width: 6),
        Flexible(child: Text('Navigasi', overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _primaryButton(bool compact) {
    final style = FilledButton.styleFrom(
      minimumSize: Size(compact ? 0 : 148, _h),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
    if (isLast) {
      return FilledButton(
        onPressed: submitting ? null : onFinish,
        style: style,
        child: submitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_rounded, size: 20),
                SizedBox(width: 6),
                Text('Selesai'),
              ]),
      );
    }
    return FilledButton(
      onPressed: onNext,
      style: style,
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Berikutnya'),
        SizedBox(width: 6),
        Icon(Icons.chevron_right_rounded, size: 20),
      ]),
    );
  }
}

// ─────────────────────────────────────────── Navigator (dipakai sheet & sidebar)

/// Panel navigasi soal: judul + ringkasan + legenda + grid nomor + tombol
/// selesai. Dipakai di bottom sheet (mobile/tablet) & sidebar kanan (desktop).
class _NavigatorPanel extends StatelessWidget {
  const _NavigatorPanel({
    required this.questions,
    required this.flagged,
    required this.currentIndex,
    required this.answered,
    required this.onJump,
    required this.onFinish,
    this.scrollController,
  });

  final List<AttemptQuestion> questions;
  final Set<int> flagged;
  final int currentIndex;
  final int answered;
  final ValueChanged<int> onJump;
  final VoidCallback onFinish;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Navigasi Soal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('Terjawab $answered/${questions.length} • ${flagged.length} ditandai',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        const _Legend(),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            primary: false,
            // maxCrossAxisExtent → kolom menyesuaikan lebar (sheet lebar / sidebar sempit).
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 52,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: questions.length,
            itemBuilder: (context, i) {
              final qq = questions[i];
              final status = flagged.contains(qq.id)
                  ? QNumStatus.flagged
                  : (qq.isAnswered ? QNumStatus.answered : QNumStatus.unanswered);
              return QuestionNumber(
                number: i + 1,
                status: status,
                active: i == currentIndex,
                onTap: () => onJump(i),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Selesaikan Tryout', icon: Icons.check_circle_rounded, onPressed: onFinish),
      ],
    );
  }
}

/// Sidebar kanan khusus desktop/laptop (lebar tetap, bisa di-scroll sendiri).
class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.width,
    required this.questions,
    required this.flagged,
    required this.currentIndex,
    required this.answered,
    required this.onJump,
    required this.onFinish,
  });

  final double width;
  final List<AttemptQuestion> questions;
  final Set<int> flagged;
  final int currentIndex;
  final int answered;
  final ValueChanged<int> onJump;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: _NavigatorPanel(
        questions: questions,
        flagged: flagged,
        currentIndex: currentIndex,
        answered: answered,
        onJump: onJump,
        onFinish: onFinish,
      ),
    );
  }
}

/// Footer desktop: Sebelumnya · Tandai · Selanjutnya (seimbang, compact).
class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter({
    required this.canPrev,
    required this.isLast,
    required this.submitting,
    required this.flagged,
    required this.onPrev,
    required this.onNext,
    required this.onToggleFlag,
    required this.onFinish,
  });

  final bool canPrev;
  final bool isLast;
  final bool submitting;
  final bool flagged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggleFlag;
  final VoidCallback onFinish;

  static const double _h = 48;

  @override
  Widget build(BuildContext context) {
    final flagColor = flagged ? AppColors.warning : AppColors.textSecondary;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          OutlinedButton.icon(
            onPressed: canPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: const Text('Sebelumnya'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, _h),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onToggleFlag,
            icon: Icon(flagged ? Icons.flag_rounded : Icons.flag_outlined, size: 18, color: flagColor),
            label: Text(flagged ? 'Ditandai' : 'Tandai'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, _h),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              foregroundColor: flagColor,
              side: BorderSide(color: flagged ? AppColors.warning : AppColors.border),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: isLast ? (submitting ? null : onFinish) : onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size(160, _h),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            child: isLast
                ? (submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: 6),
                        Text('Selesai'),
                      ]))
                : const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Selanjutnya'),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 20),
                  ]),
          ),
        ]),
      ),
    );
  }
}
