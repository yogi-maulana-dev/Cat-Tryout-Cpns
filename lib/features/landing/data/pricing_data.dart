/// Data harga landing page.
///
/// Sumber tunggal paket & promo ada di [kPackageCatalog] (lihat
/// `core/promo_config.dart`), sehingga landing page, layar paket berbayar, dan
/// pengujian memakai definisi yang sama (Bronze / Gold / Platinum).
///
/// `formatRupiah` di-re-export dari helper terpusat agar kode & test lama tetap
/// bekerja.
library;

export '../../../core/money.dart' show formatRupiah, rupiah;
export '../../../core/promo_config.dart' show kPackageCatalog, PackageTierConfig;
