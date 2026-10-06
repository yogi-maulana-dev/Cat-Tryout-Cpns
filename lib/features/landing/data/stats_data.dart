import 'package:flutter/material.dart';

@immutable
class StatItem {
  const StatItem({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;
}

/// MOCK DATA - replace with backend data later.
/// Angka di bawah adalah contoh ilustrasi, bukan data pengguna nyata.
const List<StatItem> kStats = [
  StatItem(value: '50.000+', label: 'Pengguna Aktif', icon: Icons.groups_rounded),
  StatItem(value: '10.000+', label: 'Latihan Soal', icon: Icons.quiz_rounded),
  StatItem(value: '4.9/5', label: 'Rating Pengguna', icon: Icons.star_rounded),
  StatItem(value: 'Update', label: 'Kisi-Kisi Terbaru', icon: Icons.autorenew_rounded),
];
