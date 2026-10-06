import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/features/auth/presentation/widgets/password_field.dart';

void main() {
  group('estimatePasswordStrength', () {
    test('menilai kekuatan password', () {
      expect(estimatePasswordStrength(''), PasswordStrength.lemah);
      expect(estimatePasswordStrength('abcdefgh'), PasswordStrength.lemah);
      expect(estimatePasswordStrength('Abcdef1'), PasswordStrength.sedang);
      expect(estimatePasswordStrength('Abcdefgh1234!'), PasswordStrength.kuat);
    });
  });
}
