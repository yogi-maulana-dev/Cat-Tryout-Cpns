import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/ui/ui.dart';
import '../../../../services/auth_service.dart';

/// Field CAPTCHA yang divalidasi **server-side** (aman).
///
/// Mengambil tantangan dari backend `GET /api/v1/auth/captcha` → { id, image }
/// lalu menampilkan gambar PNG. Jawaban + `captchaId` dikirim ke endpoint
/// login/register; verifikasi dilakukan Laravel (CaptchaService), bukan di
/// client. Bila captcha dinonaktifkan/tak tersedia, widget menyembunyikan diri
/// sehingga alur tetap berjalan (backend yang menentukan wajib/tidak).
class RemoteCaptchaField extends StatefulWidget {
  const RemoteCaptchaField({super.key, required this.controller, this.authService});

  final TextEditingController controller;
  final AuthService? authService;

  @override
  State<RemoteCaptchaField> createState() => RemoteCaptchaFieldState();
}

class RemoteCaptchaFieldState extends State<RemoteCaptchaField> {
  late final AuthService _auth = widget.authService ?? AuthService();

  String? _id;
  Uint8List? _bytes;
  bool _loading = true;
  bool _unavailable = false;

  /// Id captcha aktif (dikirim ke endpoint auth). Null bila captcha tak dipakai.
  String? get captchaId => _id;

  /// Apakah captcha sedang ditampilkan & wajib diisi.
  bool get available => _id != null && !_unavailable;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _auth.captcha(); // { id, image (data URI PNG) }
      _id = data['id']?.toString();
      _bytes = _decode(data['image']?.toString() ?? '');
      _unavailable = _id == null || _bytes == null;
    } catch (_) {
      // Backend mematikan captcha atau tak terjangkau → sembunyikan (best-effort).
      _id = null;
      _bytes = null;
      _unavailable = true;
    } finally {
      widget.controller.clear();
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Ambil kode captcha baru & kosongkan input.
  Future<void> refresh() => _load();

  Uint8List? _decode(String dataUri) {
    if (dataUri.isEmpty) return null;
    try {
      final i = dataUri.indexOf(',');
      return base64Decode(i >= 0 ? dataUri.substring(i + 1) : dataUri);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unavailable && !_loading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Gambar kode CAPTCHA',
                image: true,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: AppRadius.brMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _loading || _bytes == null
                      ? const SizedBox(
                          height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : Image.memory(
                          _bytes!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Ganti kode CAPTCHA',
              child: IconButton.filledTonal(
                onPressed: _loading ? null : refresh,
                icon: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                color: AppColors.primaryDark,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  minimumSize: const Size(60, 60),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: widget.controller,
          label: 'Masukkan kode CAPTCHA',
          hint: 'Ketik kode sesuai gambar',
          prefixIcon: Icons.verified_user_outlined,
          capitalization: TextCapitalization.characters,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
          validator: (v) {
            if (!available) return null; // captcha tidak dipakai
            if (v == null || v.trim().isEmpty) return 'Silakan masukkan kode CAPTCHA.';
            return null; // kebenaran diverifikasi server
          },
        ),
      ],
    );
  }
}
