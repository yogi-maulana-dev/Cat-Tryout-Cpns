import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/features/auth/presentation/widgets/remote_captcha_field.dart';

import '../../support/fake_auth_service.dart';

Future<GlobalKey<RemoteCaptchaFieldState>> _pump(
  WidgetTester tester,
  FakeAuthService fake,
  TextEditingController ctrl,
) async {
  final key = GlobalKey<RemoteCaptchaFieldState>();
  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RemoteCaptchaField(key: key, controller: ctrl, authService: fake),
      ),
    ));
    await Future.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  return key;
}

void main() {
  group('RemoteCaptchaField', () {
    testWidgets('memuat captcha dari backend & expose captchaId', (tester) async {
      final fake = FakeAuthService();
      final key = await _pump(tester, fake, TextEditingController());

      expect(fake.captchaCalls, 1);
      expect(key.currentState!.captchaId, 'cap-1');
      expect(key.currentState!.available, isTrue);
      expect(find.text('Masukkan kode CAPTCHA'), findsOneWidget);
    });

    testWidgets('refresh mengambil captcha baru & mengosongkan input', (tester) async {
      final fake = FakeAuthService();
      final ctrl = TextEditingController(text: 'ABC12');
      final key = await _pump(tester, fake, ctrl);

      await tester.runAsync(() async {
        await key.currentState!.refresh();
      });
      await tester.pump();

      expect(fake.captchaCalls, 2);
      expect(key.currentState!.captchaId, 'cap-2');
      expect(ctrl.text, isEmpty);
    });

    testWidgets('captcha tidak tersedia → widget disembunyikan', (tester) async {
      final fake = FakeAuthService(captchaEnabled: false);
      final key = await _pump(tester, fake, TextEditingController());

      expect(key.currentState!.available, isFalse);
      expect(find.text('Masukkan kode CAPTCHA'), findsNothing);
    });
  });
}
