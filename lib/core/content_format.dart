import 'api_config.dart';

/// Utilitas format konten soal/opsi (dipakai layar ujian & pembahasan).

/// Fallback ringan: bila teks mengandung HTML (mis. hasil paste dari Word via
/// editor admin), tampilkan sebagai teks biasa. Render HTML kaya / gambar inline
/// adalah peningkatan berikutnya (butuh paket seperti `flutter_html`).
String plainText(String raw) {
  if (!raw.contains('<') && !raw.contains('&')) return raw;
  return raw
      .replaceAll(RegExp(r'<\s*(br|/p|/div|/li|/h[1-6])\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .trim();
}

/// Bangun URL gambar absolut dari path/URL snapshot. Null bila kosong.
/// Aman dipakai dengan `Image.network(..., errorBuilder: ...)`.
String? resolveImageUrl(String? p) {
  if (p == null || p.trim().isEmpty) return null;
  final v = p.trim();
  if (v.startsWith('http')) return v;
  var c = v.startsWith('/') ? v.substring(1) : v;
  if (!c.startsWith('storage/')) c = 'storage/$c';
  return '${ApiConfig.host}/$c';
}
