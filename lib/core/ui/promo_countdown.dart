import 'dart:async';

import 'package:flutter/material.dart';

import '../promo.dart';
import '../server_clock.dart';
import '../theme/app_colors.dart';

/// Countdown promo yang mengacu WAKTU SERVER.
///
/// Sisa waktu dihitung dari `endsAt - clock.now()` pada setiap detik. Karena
/// [ServerClock] mengunci selisih terhadap waktu server saat data dimuat,
/// memundurkan jam perangkat atau me-refresh halaman tidak akan memperpanjang
/// promo — acuannya tetap batas yang tersimpan di server. Saat mencapai nol,
/// timer berhenti dan [onEnded] dipanggil sekali agar UI beralih ke harga normal.
class PromoCountdown extends StatefulWidget {
  const PromoCountdown({
    super.key,
    required this.clock,
    required this.endsAt,
    this.onEnded,
    this.dark = false,
  });

  final ServerClock clock;
  final DateTime endsAt;
  final VoidCallback? onEnded;

  /// true bila diletakkan di atas latar gelap/berwarna (teks terang).
  final bool dark;

  @override
  State<PromoCountdown> createState() => _PromoCountdownState();
}

class _PromoCountdownState extends State<PromoCountdown> {
  Timer? _timer;
  late Duration _remaining;
  bool _endedNotified = false;

  @override
  void initState() {
    super.initState();
    _remaining = _compute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _compute() {
    final d = widget.endsAt.toUtc().difference(widget.clock.now());
    return d.isNegative ? Duration.zero : d;
  }

  void _onTick() {
    final rem = _compute();
    if (!mounted) return;
    setState(() => _remaining = rem);
    if (rem == Duration.zero && !_endedNotified) {
      _endedNotified = true;
      _timer?.cancel();
      widget.onEnded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = CountdownParts.from(_remaining);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(p.days, 'Hari'),
        _sep(),
        _box(p.hours, 'Jam'),
        _sep(),
        _box(p.minutes, 'Menit'),
        _sep(),
        _box(p.seconds, 'Detik'),
      ],
    );
  }

  Widget _sep() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(':',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: widget.dark ? Colors.white70 : AppColors.textSecondary,
            )),
      );

  Widget _box(int value, String label) {
    final bg = widget.dark ? Colors.white.withValues(alpha: 0.18) : AppColors.primaryLight;
    final fg = widget.dark ? Colors.white : AppColors.primaryDark;
    final labelColor = widget.dark ? Colors.white70 : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10.5, color: labelColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
