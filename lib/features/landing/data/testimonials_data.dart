import 'package:flutter/material.dart';

@immutable
class Testimonial {
  const Testimonial({
    required this.name,
    required this.role,
    required this.quote,
    required this.initial,
  });
  final String name;
  final String role;
  final String quote;
  final String initial;
}

// SAMPLE TESTIMONIAL DATA
// Replace with real backend testimonials later.
// Testimoni berikut adalah contoh ilustrasi, bukan ulasan pengguna nyata.
const List<Testimonial> kTestimonials = [
  Testimonial(
    name: 'Andi Pratama',
    role: 'Peserta CPNS',
    initial: 'A',
    quote: 'Saya jadi lebih mudah memahami pola soal dan pembahasannya.',
  ),
  Testimonial(
    name: 'Siti Rahmawati',
    role: 'Peserta CPNS',
    initial: 'S',
    quote: 'Simulasinya ringan dan mudah digunakan.',
  ),
  Testimonial(
    name: 'Budi Santoso',
    role: 'Peserta CPNS',
    initial: 'B',
    quote: 'Saya lebih terarah dalam melakukan latihan.',
  ),
];
