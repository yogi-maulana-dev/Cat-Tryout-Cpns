import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:try_out_bayog/core/server_clock.dart';
import 'package:try_out_bayog/core/ui/promo_countdown.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('menampilkan label Hari/Jam/Menit/Detik & digit sisa waktu', (tester) async {
    // Jam server disinkron "sekarang"; promo berakhir 2 hari 3 jam lagi.
    final clock = ServerClock(DateTime.now().toUtc());
    final endsAt = clock.now().add(const Duration(days: 2, hours: 3, minutes: 4, seconds: 30));

    await tester.pumpWidget(host(PromoCountdown(clock: clock, endsAt: endsAt)));
    await tester.pump();

    expect(find.text('Hari'), findsOneWidget);
    expect(find.text('Jam'), findsOneWidget);
    expect(find.text('Menit'), findsOneWidget);
    expect(find.text('Detik'), findsOneWidget);
    expect(find.text('02'), findsWidgets); // 2 hari
    expect(find.text('03'), findsWidgets); // 3 jam
  });

  testWidgets('memanggil onEnded saat waktu server sudah lewat', (tester) async {
    var ended = false;
    final clock = ServerClock(DateTime.now().toUtc());
    // endsAt di masa lalu → countdown nol & onEnded terpanggil pada tick pertama.
    final endsAt = clock.now().subtract(const Duration(seconds: 5));

    await tester.pumpWidget(
      host(PromoCountdown(clock: clock, endsAt: endsAt, onEnded: () => ended = true)),
    );
    await tester.pump(const Duration(seconds: 1)); // jalankan satu tick timer

    expect(ended, isTrue);
    expect(find.text('00'), findsNWidgets(4)); // semua bagian nol
  });
}
