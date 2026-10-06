import 'package:flutter/material.dart';

@immutable
class StepItem {
  const StepItem({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

/// MOCK DATA - replace with backend data later.
const List<StepItem> kSteps = [
  StepItem(
    icon: Icons.person_add_alt_1_rounded,
    title: 'Buat Akun',
    description: 'Daftar menggunakan email atau nomor HP.',
  ),
  StepItem(
    icon: Icons.workspaces_rounded,
    title: 'Pilih Paket',
    description: 'Gunakan paket Gratis atau pilih paket sesuai kebutuhan.',
  ),
  StepItem(
    icon: Icons.play_circle_fill_rounded,
    title: 'Mulai Tryout',
    description: 'Kerjakan soal dan lihat hasilnya.',
  ),
  StepItem(
    icon: Icons.trending_up_rounded,
    title: 'Tingkatkan Skor',
    description: 'Pelajari pembahasan dan evaluasi hasil latihan.',
  ),
];
