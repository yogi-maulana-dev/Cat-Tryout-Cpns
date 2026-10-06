import 'package:flutter/material.dart';

/// Model paket harga. Dibuat agar mudah diganti dengan response API nanti
/// (mis. dari LandingRepository → Laravel API).
@immutable
class PricingPlan {
  const PricingPlan({
    required this.name,
    required this.label,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.highlighted = false,
    this.ctaText = 'Pilih Paket',
  });

  final String name;
  final String label; // badge: COBA DULU / POPULER / BEST VALUE / LENGKAP
  final int monthlyPrice; // dalam Rupiah; 0 = gratis
  final int yearlyPrice; // dalam Rupiah; 0 = gratis
  final List<String> features;
  final bool highlighted;
  final String ctaText;

  int priceFor(bool yearly) => yearly ? yearlyPrice : monthlyPrice;
}

/// Format angka ke Rupiah ("Rp 29.000"). Helper sederhana tanpa dependency.
String formatRupiah(int amount) {
  if (amount <= 0) return 'Rp 0';
  final s = amount.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// MOCK DATA - replace with backend data later.
/// Harga adalah contoh dan dapat berubah sewaktu-waktu.
const List<PricingPlan> kPricingPlans = [
  PricingPlan(
    name: 'Free',
    label: 'COBA DULU',
    monthlyPrice: 0,
    yearlyPrice: 0,
    ctaText: 'Mulai Gratis',
    features: [
      'Akses 1.000+ soal pilihan ganda',
      '1x simulasi CAT per hari',
      'Pembahasan dasar',
      'Akses semua perangkat',
    ],
  ),
  PricingPlan(
    name: 'Basic',
    label: 'POPULER',
    monthlyPrice: 29000,
    yearlyPrice: 290000,
    features: [
      '5.000+ soal lengkap',
      '5x simulasi CAT per bulan',
      'Pembahasan lengkap',
      'Analisis nilai dasar',
      'Akses semua perangkat',
    ],
  ),
  PricingPlan(
    name: 'Premium',
    label: 'BEST VALUE',
    monthlyPrice: 59000,
    yearlyPrice: 590000,
    highlighted: true,
    features: [
      'Semua fitur Basic',
      '10.000+ soal lengkap',
      'Simulasi CAT tanpa batas',
      'Analisis nilai & ranking',
      'Rekomendasi belajar personal',
    ],
  ),
  PricingPlan(
    name: 'Bundle CPNS',
    label: 'LENGKAP',
    monthlyPrice: 99000,
    yearlyPrice: 990000,
    features: [
      'Semua fitur Premium',
      'Materi belajar SKD & SKB',
      'Tryout semua formasi',
      'Video pembahasan',
      'Prioritas dukungan',
    ],
  ),
];
