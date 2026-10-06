/// Helper format mata uang Rupiah (pure Dart, tanpa dependency).
///
/// Dipusatkan di sini agar seluruh layar (paket, checkout, invoice, riwayat,
/// landing) memakai aturan format yang sama dan konsisten.
library;

/// Pengelompokan ribuan dengan titik: `30000` -> `"30.000"`.
String groupThousands(int n) {
  final neg = n < 0;
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}$buf';
}

/// Format kompak tanpa spasi: `30000` -> `"Rp30.000"`. 0/negatif -> `"Gratis"`.
String rupiah(int n) => n <= 0 ? 'Gratis' : 'Rp${groupThousands(n)}';

/// Format dengan spasi: `30000` -> `"Rp 30.000"`. 0/negatif -> `"Rp 0"`.
String formatRupiah(int n) => n <= 0 ? 'Rp 0' : 'Rp ${groupThousands(n)}';
