import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/core/theme/app_colors.dart';
import 'package:try_out_bayog/features/landing/data/faq_data.dart';
import 'package:try_out_bayog/features/landing/data/features_data.dart';
import 'package:try_out_bayog/features/landing/data/pricing_data.dart';
import 'package:try_out_bayog/features/landing/data/testimonials_data.dart';
import 'package:try_out_bayog/features/landing/presentation/pages/landing_page.dart';

/// Pump LandingPage berdiri sendiri (tanpa AuthProvider/jaringan). Landing
/// hanya memakai data mock statis, jadi aman dirender langsung.
Future<void> _pumpLanding(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(colorScheme: AppColors.scheme, useMaterial3: true),
      home: const LandingPage(),
    ),
  );
  await tester.pump();
}

/// Cari RichText yang teks polosnya memuat [text] (untuk heading dua warna).
Finder _richTextContaining(String text) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains(text),
    );

void main() {
  group('LandingPage — render', () {
    testWidgets('menampilkan judul section utama', (tester) async {
      await _pumpLanding(tester);

      // Heading hero (RichText dua warna).
      expect(_richTextContaining('Karier ASN Impianmu'), findsOneWidget);

      // Judul-judul section (Text biasa).
      expect(find.text('Kenapa Memilih BisaPNS.id?'), findsOneWidget);
      expect(find.text('Mulai Belajar Dalam 4 Langkah'), findsOneWidget);
      expect(find.text('Harga yang Fleksibel untuk Semua Kebutuhanmu'), findsOneWidget);
      expect(find.text('Rasakan Simulasi CAT yang Realistis'), findsOneWidget);
      expect(find.text('Ketahui Perkembangan Belajarmu'), findsOneWidget);
      expect(find.text('Apa Kata Mereka?'), findsOneWidget);
      expect(find.text('Pertanyaan yang Sering Diajukan'), findsOneWidget);
      expect(find.text('Jangan Tunda Persiapanmu'), findsOneWidget);
    });

    testWidgets('menampilkan CTA utama & tagline footer', (tester) async {
      await _pumpLanding(tester);

      // "Mulai Belajar Gratis" muncul di hero dan CTA.
      expect(find.text('Mulai Belajar Gratis'), findsWidgets);
      expect(find.text('Lihat Demo'), findsOneWidget);
      expect(find.text('Belajar Hari Ini, Jadi ASN Nanti.'), findsOneWidget);
    });

    testWidgets('merender semua paket harga & fitur dari data', (tester) async {
      await _pumpLanding(tester);

      for (final plan in kPricingPlans) {
        expect(find.text(plan.name), findsOneWidget, reason: 'paket ${plan.name}');
      }
      for (final f in kFeatures) {
        expect(find.text(f.title), findsOneWidget, reason: 'fitur ${f.title}');
      }
      for (final t in kTestimonials) {
        expect(find.text(t.name), findsOneWidget, reason: 'testimoni ${t.name}');
      }
      // Semua pertanyaan FAQ hadir.
      for (final q in kFaqs) {
        expect(find.text(q.question), findsOneWidget, reason: 'faq ${q.question}');
      }
    });
  });

  group('LandingPage — toggle harga', () {
    testWidgets('mengganti harga bulanan → tahunan', (tester) async {
      await _pumpLanding(tester);

      // Kondisi awal: harga bulanan Basic.
      expect(find.text('Rp 29.000'), findsOneWidget);
      expect(find.text('Rp 290.000'), findsNothing);

      final toggle = find.byKey(const Key('pricing_billing_toggle'));
      expect(toggle, findsOneWidget);

      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      // Setelah toggle: harga tahunan.
      expect(find.text('Rp 290.000'), findsOneWidget);
      expect(find.text('Rp 29.000'), findsNothing);
      // Free tetap Rp 0.
      expect(find.text('Rp 0'), findsOneWidget);
    });
  });

  group('formatRupiah', () {
    test('memformat angka ke Rupiah dengan pemisah ribuan', () {
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(-5), 'Rp 0');
      expect(formatRupiah(29000), 'Rp 29.000');
      expect(formatRupiah(290000), 'Rp 290.000');
      expect(formatRupiah(990000), 'Rp 990.000');
      expect(formatRupiah(1000000), 'Rp 1.000.000');
    });
  });
}
