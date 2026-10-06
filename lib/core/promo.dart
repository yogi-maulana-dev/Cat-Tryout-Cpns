/// Logika promo murni-Dart (tanpa Flutter) agar mudah diuji unit.
///
/// Sumber kebenaran promo tetap server: jendela waktu & harga berasal dari
/// konfigurasi/DB dan divalidasi ulang saat order dibuat. Kelas di sini hanya
/// menghitung status/sisa-waktu dari sebuah instant agar UI dapat menampilkan
/// badge, harga coret, dan countdown secara konsisten.
library;

/// Fase promo pada suatu waktu.
enum PromoState {
  /// Tidak ada promo terkonfigurasi untuk paket ini.
  none,

  /// Promo sudah diatur namun periode belum mulai.
  notStarted,

  /// Promo sedang berlangsung.
  active,

  /// Periode promo sudah lewat.
  ended,
}

/// Jendela promo: instant mulai & berakhir (disimpan UTC; batas akhir inklusif).
class PromoWindow {
  /// Instant mulai promo (inklusif).
  final DateTime startsAt;

  /// Instant berakhir promo (inklusif — detik terakhir masih promo).
  final DateTime endsAt;

  const PromoWindow({required this.startsAt, required this.endsAt});

  DateTime get _start => startsAt.toUtc();
  DateTime get _end => endsAt.toUtc();

  /// Fase promo pada [now].
  PromoState stateAt(DateTime now) {
    final n = now.toUtc();
    if (n.isBefore(_start)) return PromoState.notStarted;
    if (n.isAfter(_end)) return PromoState.ended;
    return PromoState.active;
  }

  bool isActiveAt(DateTime now) => stateAt(now) == PromoState.active;

  /// Sisa waktu hingga promo berakhir (0 bila sudah lewat).
  Duration remainingAt(DateTime now) {
    final d = _end.difference(now.toUtc());
    return d.isNegative ? Duration.zero : d;
  }

  /// Sisa waktu hingga promo mulai (0 bila sudah dimulai).
  Duration untilStartAt(DateTime now) {
    final d = _start.difference(now.toUtc());
    return d.isNegative ? Duration.zero : d;
  }
}

/// Pecahan durasi untuk countdown: hari/jam/menit/detik.
class CountdownParts {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  const CountdownParts(this.days, this.hours, this.minutes, this.seconds);

  factory CountdownParts.from(Duration d) {
    var s = d.isNegative ? 0 : d.inSeconds;
    final days = s ~/ 86400;
    s %= 86400;
    final hours = s ~/ 3600;
    s %= 3600;
    final minutes = s ~/ 60;
    final seconds = s % 60;
    return CountdownParts(days, hours, minutes, seconds);
  }

  bool get isZero => days == 0 && hours == 0 && minutes == 0 && seconds == 0;
}

/// Persentase diskon dari harga normal ke harga promo (dibulatkan).
int discountPercent(int normalPrice, int promoPrice) {
  if (normalPrice <= 0 || promoPrice < 0 || promoPrice >= normalPrice) return 0;
  return (((normalPrice - promoPrice) / normalPrice) * 100).round();
}
