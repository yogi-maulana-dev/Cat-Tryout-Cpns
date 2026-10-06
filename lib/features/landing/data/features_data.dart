import 'package:flutter/material.dart';

@immutable
class FeatureItem {
  const FeatureItem({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

/// MOCK DATA - replace with backend data later.
const List<FeatureItem> kFeatures = [
  FeatureItem(
    icon: Icons.menu_book_rounded,
    title: 'Soal Lengkap & Terbaru',
    description: 'Ribuan soal sesuai kisi-kisi SKD dan SKB dari berbagai formasi.',
  ),
  FeatureItem(
    icon: Icons.desktop_windows_rounded,
    title: 'Simulasi CAT Realistis',
    description: 'Rasakan pengalaman ujian seperti CAT dengan sistem yang terstruktur.',
  ),
  FeatureItem(
    icon: Icons.insights_rounded,
    title: 'Analisis Hasil & Pembahasan',
    description: 'Lihat detail performa dan pembahasan setiap soal secara lengkap.',
  ),
  FeatureItem(
    icon: Icons.devices_rounded,
    title: 'Akses di Semua Perangkat',
    description: 'Belajar kapan saja dan di mana saja melalui HP, tablet, atau laptop.',
  ),
  FeatureItem(
    icon: Icons.support_agent_rounded,
    title: 'Dukungan Pembelajaran',
    description: 'Temukan panduan dan materi untuk membantu proses belajar.',
  ),
  FeatureItem(
    icon: Icons.savings_rounded,
    title: 'Harga Terjangkau',
    description: 'Mulai belajar gratis dan pilih paket sesuai kebutuhan.',
  ),
];
