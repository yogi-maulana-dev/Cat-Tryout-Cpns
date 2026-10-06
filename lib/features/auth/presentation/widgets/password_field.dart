import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/ui/ui.dart';

/// Field password bertema design-system (top-label, show/hide bawaan) dengan
/// indikator kekuatan password opsional.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.showStrength = false,
    this.textInputAction,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool showStrength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: widget.controller,
          label: widget.label,
          obscure: true,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: widget.textInputAction,
          onChanged: (v) {
            if (widget.showStrength) setState(() {});
            widget.onChanged?.call(v);
          },
          validator: widget.validator ??
              (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
        ),
        if (widget.showStrength) ...[
          const SizedBox(height: 8),
          _StrengthBar(password: widget.controller.text),
        ],
      ],
    );
  }
}

enum PasswordStrength { lemah, sedang, kuat }

/// Hitung kekuatan password sederhana (panjang + variasi karakter).
PasswordStrength estimatePasswordStrength(String p) {
  if (p.isEmpty) return PasswordStrength.lemah;
  var score = 0;
  if (p.length >= 8) score++;
  if (p.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) score++;
  if (RegExp(r'\d').hasMatch(p)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
  if (score <= 1) return PasswordStrength.lemah;
  if (score <= 3) return PasswordStrength.sedang;
  return PasswordStrength.kuat;
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final s = estimatePasswordStrength(password);
    final (label, color, fraction) = switch (s) {
      PasswordStrength.lemah => ('Lemah', AppColors.danger, 0.33),
      PasswordStrength.sedang => ('Sedang', AppColors.warning, 0.66),
      PasswordStrength.kuat => ('Kuat', AppColors.primary, 1.0),
    };
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.brPill,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('Kekuatan: $label',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
