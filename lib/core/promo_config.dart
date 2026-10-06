import 'promo.dart';
import 'wib.dart';

/// Konfigurasi paket & promo default (mirror dari kebijakan backend BisaPNS.id).
///
/// CATATAN PENTING:
///  - Ini adalah SATU sumber nilai default untuk tampilan (landing page dan
///    fallback). Pada alur berbayar, data paket & harga diambil dari server
///    (`GET /packages`) dan harga transaksi final ditentukan server saat order
///    dibuat — nilai di sini tidak dipakai untuk menagih.
///  - Nilai promo (periode mulai/berakhir, harga normal/promo) sengaja dibuat
///    mudah diubah admin. Backend menyimpan nilai ini di DB/konfigurasi dan
///    mengirimnya lewat API; konstanta di sini harus disamakan dengan backend.
class PackageTierConfig {
  final String slug; // bronze | gold | platinum
  final String name;
  final String tagline;
  final int normalPrice; // Rupiah; 0 = gratis
  final int? promoPrice; // Rupiah; null = tidak ada promo harga
  final int tryoutQuota; // jumlah try out (0 = tidak relevan/unlimited)
  final int durationDays; // masa aktif paket
  final PromoWindow? promoWindow;
  final bool isPopular;
  final List<String> features;

  const PackageTierConfig({
    required this.slug,
    required this.name,
    required this.tagline,
    required this.normalPrice,
    this.promoPrice,
    required this.tryoutQuota,
    required this.durationDays,
    this.promoWindow,
    this.isPopular = false,
    required this.features,
  });

  bool get isFree => normalPrice <= 0;

  int get discount =>
      promoPrice == null ? 0 : discountPercent(normalPrice, promoPrice!);
}

/// Promo Platinum: 6 Okt 2026 00:00 WIB s/d 6 Nov 2026 23:59 WIB (inklusif).
final PromoWindow kPlatinumPromoWindow = PromoWindow(
  startsAt: wib(2026, 10, 6, 0, 0, 0),
  endsAt: wib(2026, 11, 6, 23, 59, 59),
);

/// Katalog default 3 paket sesuai kebijakan BisaPNS.id.
final List<PackageTierConfig> kPackageCatalog = [
  const PackageTierConfig(
    slug: 'bronze',
    name: 'Bronze',
    tagline: 'Coba gratis dulu',
    normalPrice: 0,
    tryoutQuota: 1,
    durationDays: 7,
    features: [
      '1x try out gratis',
      'Soal TWK, TIU, dan TKP',
      'Timer ujian & skor otomatis',
      'Pembahasan dasar',
    ],
  ),
  const PackageTierConfig(
    slug: 'gold',
    name: 'Gold',
    tagline: 'Paling banyak dipilih',
    normalPrice: 10000,
    tryoutQuota: 10,
    durationDays: 30,
    isPopular: true,
    features: [
      '10x try out',
      'Pembahasan soal lengkap',
      'Analisis nilai',
      'Riwayat hasil',
      'Leaderboard peserta',
    ],
  ),
  PackageTierConfig(
    slug: 'platinum',
    name: 'Platinum',
    tagline: 'Persiapan paling lengkap',
    normalPrice: 30000,
    promoPrice: 15000,
    tryoutQuota: 30,
    durationDays: 60,
    promoWindow: kPlatinumPromoWindow,
    features: [
      '30x try out',
      'Pembahasan lengkap + strategi',
      'Analisis kelemahan per kategori',
      'Grafik perkembangan nilai',
      'Leaderboard peserta',
    ],
  ),
];

/// Cari konfigurasi default berdasarkan slug/nama paket (case-insensitive).
PackageTierConfig? tierConfigFor(String? slugOrName) {
  if (slugOrName == null) return null;
  final key = slugOrName.toLowerCase().trim();
  for (final c in kPackageCatalog) {
    if (key == c.slug || key.contains(c.slug) || c.name.toLowerCase() == key) {
      return c;
    }
  }
  return null;
}
