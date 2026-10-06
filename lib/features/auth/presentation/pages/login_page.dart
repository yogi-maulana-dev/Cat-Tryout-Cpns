import 'package:flutter/material.dart';
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

/// Halaman Login BisaPNS.id (route: /login).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService});

  /// Untuk testing: injeksi AuthService (mis. fake). Default null → captcha
  /// memakai AuthService bawaan.
  final AuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _captchaKey = GlobalKey<RemoteCaptchaFieldState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _captcha = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _captcha.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final capId = _captchaKey.currentState?.captchaId;
      await context.read<AuthProvider>().login(
            _email.text.trim(),
            _password.text,
            captchaId: capId,
            captcha: capId != null ? _captcha.text.trim() : null,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst); // SplashScreen → HomeScreen
    } on ApiException catch (e) {
      setState(() => _error = e.firstError);
      _captchaKey.currentState?.refresh(); // captcha sekali pakai → ambil baru
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
      title: 'Masuk',
      subtitle: 'Masuk untuk melanjutkan persiapan CPNS-mu.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            PasswordField(controller: _password, textInputAction: TextInputAction.done),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
                child: const Text('Lupa Password?'),
              ),
            ),
            const SizedBox(height: 10),
            RemoteCaptchaField(
              key: _captchaKey,
              controller: _captcha,
              authService: widget.authService,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthMessageBox(message: _error!),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Masuk',
              icon: Icons.login_rounded,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Belum punya akun? ', style: AppTextStyles.bodySmall),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/register'),
                  child: Text('Daftar sekarang',
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
