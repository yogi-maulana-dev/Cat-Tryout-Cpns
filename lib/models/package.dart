import '../core/promo.dart';
import '../core/promo_config.dart';

/// Paket tryout (dari `GET /packages`).
///
/// Server adalah sumber kebenaran harga & promo. Model ini membawa harga
/// normal, harga promo (bila ada), serta jendela promo (mulai/berakhir) yang
/// dikonfigurasi admin di backend. UI memakai waktu server (lihat [ServerClock])
/// untuk menentukan apakah promo sedang aktif, menampilkan harga coret, badge
/// diskon, dan countdown. Harga yang ditagih tetap dihitung ulang server saat
/// order dibuat — nilai di sini hanya untuk tampilan.
class Package {
  final int id;
  final String name;
  final String? slug;
  final String? description;

  /// Harga normal (sebelum promo), Rupiah.
  final int normalPrice;

  /// Harga promo bila dikonfigurasi, Rupiah. null = tidak ada promo harga.
  final int? promoPrice;

  /// Jendela promo dari konfigurasi/DB server. null = tidak ada promo.
  final PromoWindow? promoWindow;

  /// Flag promo dari server (mis. admin menonaktifkan promo). Default true agar
  /// jendela promo tetap dihormati bila backend belum mengirim flag ini.
  final bool promoEnabled;

  /// Diskon (%) dari server; bila null dihitung dari selisih harga.
  final int? serverDiscountPercent;

  /// Jumlah try out yang didapat. null = tidak terbatas.
  final int? tryoutQuota;

  /// Masa aktif paket (hari).
  final int durationDays;

  final List<String> features;
  final bool isPopular;

  // Kompatibilitas lama (period bulanan/tahunan).
  final int priceMonthly;
  final int priceYearly;

  Package({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.normalPrice,
    this.promoPrice,
    this.promoWindow,
    this.promoEnabled = true,
    this.serverDiscountPercent,
    this.tryoutQuota,
    required this.durationDays,
    required this.features,
    required this.isPopular,
    this.priceMonthly = 0,
    this.priceYearly = 0,
  });

  bool get isFree =>
      normalPrice <= 0 && (promoPrice ?? 0) <= 0 && priceMonthly == 0 && priceYearly == 0;

  /// Promo harga valid bila ada jendela, harga promo, dan harga promo < normal.
  bool get hasPromo =>
      promoEnabled &&
      promoWindow != null &&
      promoPrice != null &&
      promoPrice! < normalPrice;

  /// Fase promo pada waktu server [serverNow].
  PromoState promoStateAt(DateTime serverNow) =>
      hasPromo ? promoWindow!.stateAt(serverNow) : PromoState.none;

  bool isPromoActiveAt(DateTime serverNow) =>
      promoStateAt(serverNow) == PromoState.active;

  /// Harga yang BERLAKU untuk ditampilkan pada waktu server [serverNow].
  /// (Harga final transaksi tetap ditentukan server saat order dibuat.)
  int effectivePriceAt(DateTime serverNow) =>
      isPromoActiveAt(serverNow) ? promoPrice! : normalPrice;

  /// Persentase diskon efektif.
  int get discountPercentValue =>
      serverDiscountPercent ??
      (promoPrice != null ? discountPercent(normalPrice, promoPrice!) : 0);

  /// Sisa waktu promo pada waktu server (Duration.zero bila tak aktif/habis).
  Duration promoRemainingAt(DateTime serverNow) =>
      hasPromo ? promoWindow!.remainingAt(serverNow) : Duration.zero;

  /// Kompat lama: harga per periode (dipakai sebagian UI lama).
  int priceFor(bool yearly) =>
      yearly ? (priceYearly != 0 ? priceYearly : normalPrice) : (priceMonthly != 0 ? priceMonthly : normalPrice);

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory Package.fromJson(Map<String, dynamic> j) {
    final priceMonthly = (j['price_monthly'] ?? 0) as int;
    final priceYearly = (j['price_yearly'] ?? 0) as int;

    // Harga normal: utamakan field baru, fallback ke harga period lama.
    final normal = (j['normal_price'] ??
            j['price'] ??
            (priceMonthly != 0 ? priceMonthly : priceYearly)) as int? ??
        0;

    final promo = j['promo_price'] as int?;
    final starts = _date(j['promo_starts_at'] ?? j['promo_start_at']);
    final ends = _date(j['promo_ends_at'] ?? j['promo_end_at']);
    final window = (starts != null && ends != null)
        ? PromoWindow(startsAt: starts, endsAt: ends)
        : null;

    return Package(
      id: j['id'] as int,
      name: j['name'] as String,
      slug: j['slug'] as String?,
      description: j['description'] as String?,
      normalPrice: normal,
      promoPrice: promo,
      promoWindow: window,
      promoEnabled: j['promo_enabled'] == null ? true : j['promo_enabled'] == true,
      serverDiscountPercent: j['discount_percent'] as int?,
      tryoutQuota: j['tryout_quota'] as int? ?? j['tryout_limit'] as int?,
      durationDays: (j['duration_days'] ?? 30) as int,
      features:
          ((j['features'] as List?) ?? const []).map((e) => e.toString()).toList(),
      isPopular: (j['is_popular'] ?? false) as bool,
      priceMonthly: priceMonthly,
      priceYearly: priceYearly,
    );
  }

  /// Bangun paket tampilan dari konfigurasi default (landing/fallback).
  factory Package.fromConfig(PackageTierConfig c, {required int id}) => Package(
        id: id,
        name: c.name,
        slug: c.slug,
        description: c.tagline,
        normalPrice: c.normalPrice,
        promoPrice: c.promoPrice,
        promoWindow: c.promoWindow,
        serverDiscountPercent: c.promoPrice == null ? null : c.discount,
        tryoutQuota: c.tryoutQuota,
        durationDays: c.durationDays,
        features: c.features,
        isPopular: c.isPopular,
      );
}
