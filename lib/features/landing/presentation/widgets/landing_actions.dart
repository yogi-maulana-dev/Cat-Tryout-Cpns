import 'package:flutter/material.dart';

/// Kumpulan aksi navigasi & scroll landing page, di-pass ke section/navbar.
///
/// CTA menuju halaman auth memakai named route (didaftarkan di main.dart):
/// `/login`, `/register`, `/forgot-password`. Section Fitur/Paket/FAQ/Demo
/// memakai smooth-scroll dalam halaman.
@immutable
class LandingActions {
  const LandingActions({
    required this.scrollToFeatures,
    required this.scrollToPricing,
    required this.scrollToFaq,
    required this.scrollToDemo,
    required this.scrollToTop,
  });

  final VoidCallback scrollToFeatures;
  final VoidCallback scrollToPricing;
  final VoidCallback scrollToFaq;
  final VoidCallback scrollToDemo;
  final VoidCallback scrollToTop;

  /// CTA "Daftar Sekarang" / "Mulai Belajar Gratis" → /register.
  void goRegister(BuildContext context) => Navigator.of(context).pushNamed('/register');

  /// CTA "Masuk" → /login.
  void goLogin(BuildContext context) => Navigator.of(context).pushNamed('/login');
}
