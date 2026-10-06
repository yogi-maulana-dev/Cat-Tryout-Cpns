/// Helper zona waktu WIB (Asia/Jakarta = UTC+7, tanpa DST — offset tetap).
///
/// Semua batas promo disimpan sebagai instant UTC. Untuk menampilkan ke
/// pengguna kita ubah ke "wall clock" WIB. Karena WIB tidak pernah memakai
/// daylight saving, offset +7 jam konstan sepanjang tahun sehingga aman
/// di-hardcode tanpa database zona waktu.
library;

const Duration kWibOffset = Duration(hours: 7);

/// Buat instant UTC dari komponen waktu dinding (wall clock) WIB.
///
/// Contoh: akhir promo "6 Nov 2026 23:59 WIB" => `wib(2026, 11, 6, 23, 59, 59)`.
DateTime wib(int year, int month, int day,
        [int hour = 0, int minute = 0, int second = 0]) =>
    DateTime.utc(year, month, day, hour, minute, second).subtract(kWibOffset);

/// Ubah instant apa pun menjadi wall clock WIB (sebagai DateTime UTC yang
/// nilainya sudah digeser +7 jam — gunakan hanya untuk diformat, bukan dibanding).
DateTime toWib(DateTime instant) => instant.toUtc().add(kWibOffset);

const List<String> _monthsId = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Format tanggal-jam WIB ringkas: "6 Nov 2026, 23:59 WIB".
String formatWib(DateTime instant) {
  final w = toWib(instant);
  return '${w.day} ${_monthsId[w.month - 1]} ${w.year}, '
      '${_two(w.hour)}:${_two(w.minute)} WIB';
}
