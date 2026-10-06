import 'package:flutter_test/flutter_test.dart';
import 'package:try_out_bayog/core/money.dart';
import 'package:try_out_bayog/core/promo.dart';
import 'package:try_out_bayog/core/promo_config.dart';
import 'package:try_out_bayog/core/server_clock.dart';
import 'package:try_out_bayog/core/wib.dart';
import 'package:try_out_bayog/models/package.dart';

void main() {
  group('money', () {
    test('groupThousands memisahkan ribuan', () {
      expect(groupThousands(0), '0');
      expect(groupThousands(30000), '30.000');
      expect(groupThousands(1000000), '1.000.000');
    });

    test('rupiah kompak, Gratis untuk 0', () {
      expect(rupiah(0), 'Gratis');
      expect(rupiah(10000), 'Rp10.000');
      expect(rupiah(15000), 'Rp15.000');
      expect(rupiah(30000), 'Rp30.000');
    });

    test('formatRupiah dengan spasi, Rp 0 untuk 0/negatif', () {
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(-5), 'Rp 0');
      expect(formatRupiah(29000), 'Rp 29.000');
    });
  });

  group('discountPercent', () {
    test('menghitung diskon', () {
      expect(discountPercent(30000, 15000), 50);
      expect(discountPercent(10000, 7500), 25);
    });
    test('mengembalikan 0 bila tidak valid', () {
      expect(discountPercent(0, 0), 0);
      expect(discountPercent(10000, 10000), 0);
      expect(discountPercent(10000, 12000), 0);
    });
  });

  group('PromoWindow — fase & batas waktu', () {
    final start = wib(2026, 10, 6, 0, 0, 0);
    final end = wib(2026, 11, 6, 23, 59, 59);
    final win = PromoWindow(startsAt: start, endsAt: end);

    test('sebelum mulai → notStarted', () {
      expect(win.stateAt(wib(2026, 10, 5, 23, 59, 59)), PromoState.notStarted);
      expect(win.stateAt(wib(2026, 10, 1)), PromoState.notStarted);
    });

    test('tepat di awal (inklusif) → active', () {
      expect(win.stateAt(start), PromoState.active);
    });

    test('di tengah periode → active', () {
      expect(win.stateAt(wib(2026, 10, 20, 12)), PromoState.active);
    });

    test('tepat di akhir (inklusif) → active', () {
      expect(win.stateAt(end), PromoState.active);
    });

    test('satu detik setelah akhir → ended', () {
      expect(win.stateAt(end.add(const Duration(seconds: 1))), PromoState.ended);
    });

    test('setelah periode → ended', () {
      expect(win.stateAt(wib(2026, 12, 1)), PromoState.ended);
    });

    test('remainingAt & untilStartAt', () {
      expect(win.untilStartAt(wib(2026, 10, 5, 23, 59, 59)), const Duration(seconds: 1));
      expect(win.untilStartAt(wib(2026, 10, 20)), Duration.zero); // sudah mulai
      expect(win.remainingAt(end.subtract(const Duration(minutes: 1))), const Duration(minutes: 1));
      expect(win.remainingAt(end.add(const Duration(days: 1))), Duration.zero);
    });
  });

  group('CountdownParts', () {
    test('memecah durasi', () {
      final p = CountdownParts.from(const Duration(days: 2, hours: 3, minutes: 4, seconds: 5));
      expect([p.days, p.hours, p.minutes, p.seconds], [2, 3, 4, 5]);
    });
    test('durasi negatif → nol', () {
      expect(CountdownParts.from(const Duration(seconds: -10)).isZero, isTrue);
    });
  });

  group('Package — harga promo Platinum (sebelum / selama / sesudah)', () {
    final platinumCfg = kPackageCatalog.firstWhere((c) => c.slug == 'platinum');
    final platinum = Package.fromConfig(platinumCfg, id: 3);

    test('konfigurasi sesuai kebijakan', () {
      expect(platinum.normalPrice, 30000);
      expect(platinum.promoPrice, 15000);
      expect(platinum.tryoutQuota, 30);
      expect(platinum.hasPromo, isTrue);
      expect(platinum.discountPercentValue, 50);
    });

    test('SEBELUM promo → harga normal 30.000', () {
      final t = wib(2026, 10, 1);
      expect(platinum.promoStateAt(t), PromoState.notStarted);
      expect(platinum.isPromoActiveAt(t), isFalse);
      expect(platinum.effectivePriceAt(t), 30000);
    });

    test('SELAMA promo → harga promo 15.000', () {
      final t = wib(2026, 10, 20, 10);
      expect(platinum.promoStateAt(t), PromoState.active);
      expect(platinum.isPromoActiveAt(t), isTrue);
      expect(platinum.effectivePriceAt(t), 15000);
    });

    test('BATAS tepat akhir (23:59:59 WIB) → masih promo 15.000', () {
      final t = wib(2026, 11, 6, 23, 59, 59);
      expect(platinum.effectivePriceAt(t), 15000);
    });

    test('SATU detik setelah akhir → kembali 30.000', () {
      final t = wib(2026, 11, 6, 23, 59, 59).add(const Duration(seconds: 1));
      expect(platinum.promoStateAt(t), PromoState.ended);
      expect(platinum.effectivePriceAt(t), 30000);
    });

    test('SESUDAH promo → harga normal 30.000', () {
      final t = wib(2026, 12, 1);
      expect(platinum.effectivePriceAt(t), 30000);
    });

    test('promoEnabled=false → promo diabaikan meski dalam periode', () {
      final disabled = Package.fromConfig(platinumCfg, id: 3);
      final off = Package(
        id: disabled.id,
        name: disabled.name,
        slug: disabled.slug,
        normalPrice: disabled.normalPrice,
        promoPrice: disabled.promoPrice,
        promoWindow: disabled.promoWindow,
        promoEnabled: false,
        tryoutQuota: disabled.tryoutQuota,
        durationDays: disabled.durationDays,
        features: disabled.features,
        isPopular: disabled.isPopular,
      );
      final t = wib(2026, 10, 20);
      expect(off.hasPromo, isFalse);
      expect(off.effectivePriceAt(t), 30000);
    });
  });

  group('Package.fromJson — parsing & fallback', () {
    test('field promo baru', () {
      final p = Package.fromJson({
        'id': 3,
        'name': 'Platinum',
        'slug': 'platinum',
        'normal_price': 30000,
        'promo_price': 15000,
        'promo_starts_at': '2026-10-05T17:00:00Z',
        'promo_ends_at': '2026-11-06T16:59:59Z',
        'discount_percent': 50,
        'tryout_quota': 30,
        'duration_days': 60,
        'features': ['a', 'b'],
        'is_popular': true,
      });
      expect(p.normalPrice, 30000);
      expect(p.promoPrice, 15000);
      expect(p.hasPromo, isTrue);
      expect(p.tryoutQuota, 30);
      expect(p.durationDays, 60);
      expect(p.isPromoActiveAt(wib(2026, 10, 20)), isTrue);
      expect(p.effectivePriceAt(wib(2026, 10, 20)), 15000);
    });

    test('fallback dari price_monthly lama', () {
      final p = Package.fromJson({
        'id': 2,
        'name': 'Gold',
        'price_monthly': 10000,
        'duration_days': 30,
        'features': [],
        'is_popular': false,
      });
      expect(p.normalPrice, 10000);
      expect(p.promoPrice, isNull);
      expect(p.hasPromo, isFalse);
      expect(p.effectivePriceAt(DateTime.now()), 10000);
    });

    test('paket gratis', () {
      final p = Package.fromJson({
        'id': 1,
        'name': 'Bronze',
        'normal_price': 0,
        'duration_days': 7,
        'features': [],
        'is_popular': false,
      });
      expect(p.isFree, isTrue);
    });
  });

  group('ServerClock', () {
    test('now mengikuti waktu server saat sinkron (bukan device)', () {
      // Server 2 jam di depan perangkat; disinkron pada saat ini.
      final server = DateTime.now().toUtc().add(const Duration(hours: 2));
      final clock = ServerClock(server);
      // Tepat setelah sinkron, now() ≈ waktu server (elapsed ~0 detik).
      expect(clock.now().difference(server).inSeconds.abs() < 5, isTrue);
      // Skew tercatat ≈ +2 jam (server - device).
      expect((clock.skew - const Duration(hours: 2)).inSeconds.abs() < 5, isTrue);
    });

    test('memundurkan device tidak memundurkan now (acuan tetap server)', () {
      final server = DateTime.now().toUtc();
      // Perangkat tertinggal 10 menit saat sinkron.
      final device = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final clock = ServerClock(server, deviceTime: device);
      // now() memproyeksikan dari server + elapsed device sejak sinkron (~10 mnt).
      expect(clock.now().isAfter(server.add(const Duration(minutes: 9))), isTrue);
    });
  });
}
