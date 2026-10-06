import 'package:flutter/material.dart';

import '../../../../core/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../../../../services/auth_service.dart';
import '../widgets/auth_error_box.dart';
import '../widgets/auth_scaffold.dart';

/// Halaman Lupa Password BisaPNS.id (route: /forgot-password).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _email = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.forgotPassword(_email.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } on ApiException catch (e) {
      setState(() => _error = e.firstError);
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Lupa Password',
      subtitle: 'Masukkan email akunmu untuk menerima tautan reset password.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_sent)
              const AuthMessageBox(
                success: true,
                message: 'Jika email terdaftar, tautan reset telah dikirim. Silakan cek kotak masuk.',
              )
            else ...[
              AppTextField(
                controller: _email,
                label: 'Email',
                hint: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                AuthMessageBox(message: _error!),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Kirim Tautan Reset',
                icon: Icons.send_rounded,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Kembali ke Masuk'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
