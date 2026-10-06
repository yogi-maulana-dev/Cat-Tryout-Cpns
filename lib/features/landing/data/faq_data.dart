import 'package:flutter/material.dart';

@immutable
class FaqItem {
  const FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

/// MOCK DATA - replace with backend data later.
const List<FaqItem> kFaqs = [
  FaqItem(
    question: 'Apakah BisaPNS.id gratis?',
    answer: 'Ya. Tersedia paket Gratis yang dapat digunakan tanpa berlangganan.',
  ),
  FaqItem(
    question: 'Apa saja materi yang tersedia?',
    answer:
        'Materi dan latihan dapat mencakup berbagai kategori persiapan CPNS sesuai layanan yang tersedia.',
  ),
  FaqItem(
    question: 'Apakah bisa digunakan melalui HP?',
    answer:
        'Ya. Website dirancang responsive dan dapat digunakan melalui HP, tablet, maupun laptop.',
  ),
  FaqItem(
    question: 'Apakah simulasi CAT menggunakan timer?',
    answer:
        'Ya, simulasi dapat menggunakan sistem waktu untuk memberikan pengalaman latihan yang lebih terstruktur.',
  ),
  FaqItem(
    question: 'Apakah ada pembahasan soal?',
    answer: 'Ya, paket tertentu menyediakan pembahasan soal.',
  ),
  FaqItem(
    question: 'Bagaimana cara membeli paket?',
    answer:
        'Pengguna dapat memilih paket, melakukan pembayaran sesuai metode yang tersedia, kemudian paket akan aktif pada akun.',
  ),
];
