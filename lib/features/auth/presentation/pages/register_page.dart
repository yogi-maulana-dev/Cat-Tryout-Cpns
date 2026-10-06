import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/ui.dart';
import '../../../../services/auth_service.dart';
import '../../../../state/auth_provider.dart';
import '../widgets/auth_error_box.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';
import '../widgets/remote_captcha_field.dart';

/// Halaman Registrasi BisaPNS.id (route: /register).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.authService});

  /// Untuk testing: injeksi AuthService (mis. fake).
  final AuthService? authService;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _captchaKey = GlobalKey<RemoteCaptchaFieldState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _captcha = TextEditingController();

  bool _agree = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Aktifkan/nonaktifkan tombol saat input CAPTCHA berubah.
    _captcha.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _captcha.removeListener(_onChanged);
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _captcha.dispose();
    super.dispose();
  }

  // Captcha diverifikasi server-side; di client cukup pastikan sudah diisi
  // (atau captcha memang tidak dipakai backend).
  bool get _captchaReady {
    final st = _captchaKey.currentState;
    if (st == null || !st.available) return true;
    return _captcha.text.trim().isNotEmpty;
  }

  bool get _canSubmit => _agree && _captchaReady && !_loading;

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final capId = _captchaKey.currentState?.captchaId;
      await context.read<AuthProvider>().register(
            _name.text.trim(),
            _email.text.trim(),
            _password.text,
            nomorHp: _phone.text.trim(),
            captchaId: capId,
            captcha: capId != null ? _captcha.text.trim() : null,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on ApiException catch (e) {
      setState(() => _error = e.firstError);
      _captchaKey.currentState?.refresh();
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
      _captchaKey.currentState?.refresh();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Daftar Akun',
      subtitle: 'Buat akun gratis untuk mulai berlatih tryout CPNS.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              label: 'Nama Lengkap',
              hint: 'Nama sesuai identitas',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              capitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _email,
              label: 'Email',
              hint: 'nama@email.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phone,
              label: 'Nomor HP',
              hint: '08xxxxxxxxxx',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Nomor HP wajib diisi';
                if (s.replaceAll('+', '').length < 9) return 'Nomor HP tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordField(controller: _password, showStrength: true),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: 'Konfirmasi Password',
              textInputAction: TextInputAction.done,
              validator: (v) => v != _password.text ? 'Konfirmasi password tidak sama' : null,
            ),
            const SizedBox(height: 16),
            RemoteCaptchaField(
              key: _captchaKey,
              controller: _captcha,
              authService: widget.authService,
            ),
            const SizedBox(height: 8),
            _TermsCheckbox(value: _agree, onChanged: (v) => setState(() => _agree = v)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthMessageBox(message: _error!),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Daftar Sekarang',
              icon: Icons.person_add_alt_1_rounded,
              loading: _loading,
              onPressed: _canSubmit ? _submit : null,
            ),
            if (!_canSubmit && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Setujui S&K dan isi CAPTCHA untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Sudah punya akun? ', style: AppTextStyles.bodySmall),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: Text('Masuk',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.bodySmall,
                  children: [
                    TextSpan(text: 'Saya menyetujui '),
                    TextSpan(
                        text: 'Syarat & Ketentuan',
                        style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                    TextSpan(text: ' dan '),
                    TextSpan(
                        text: 'Kebijakan Privasi',
                        style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
