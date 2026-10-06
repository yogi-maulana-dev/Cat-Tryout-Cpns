import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:try_out_bayog/core/ui/ui.dart';
import 'package:try_out_bayog/features/auth/presentation/pages/login_page.dart';
import 'package:try_out_bayog/features/auth/presentation/pages/register_page.dart';
import 'package:try_out_bayog/state/auth_provider.dart';

import '../../support/fake_auth_service.dart';

Widget _wrap(Widget page) => ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(auth: FakeAuthService()),
      child: MaterialApp(
        home: page,
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
        },
      ),
    );

/// Pump + tunggu captcha (async) selesai dimuat.
Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(page));
    await Future.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
}

void main() {
  group('LoginPage', () {
    testWidgets('menampilkan field, captcha backend & tautan', (tester) async {
      await _pumpPage(tester, LoginPage(authService: FakeAuthService()));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Masukkan kode CAPTCHA'), findsOneWidget);
      expect(find.text('Lupa Password?'), findsOneWidget);
      expect(find.text('Daftar sekarang'), findsOneWidget);
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('validasi menolak email kosong', (tester) async {
      await _pumpPage(tester, LoginPage(authService: FakeAuthService()));

      final submit = find.widgetWithText(PrimaryButton, 'Masuk');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(find.text('Masukkan email yang valid'), findsOneWidget);
    });
  });

  group('RegisterPage', () {
    testWidgets('menampilkan seluruh field registrasi + Nomor HP', (tester) async {
      await _pumpPage(tester, RegisterPage(authService: FakeAuthService()));

      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Nomor HP'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.text('Masukkan kode CAPTCHA'), findsOneWidget);
    });

    testWidgets('checkbox S&K tersedia untuk gating', (tester) async {
      await _pumpPage(tester, RegisterPage(authService: FakeAuthService()));
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
