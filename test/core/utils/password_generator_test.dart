import 'package:flutter_test/flutter_test.dart';
import 'package:saree_sutra/core/utils/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('generates password with requested length', () {
      final pass12 = PasswordGenerator.generateTemporaryPassword(length: 12);
      expect(pass12.length, 12);

      final pass16 = PasswordGenerator.generateTemporaryPassword(length: 16);
      expect(pass16.length, 16);
    });

    test('rejects length less than 8', () {
      expect(
        () => PasswordGenerator.generateTemporaryPassword(length: 7),
        throwsArgumentError,
      );
    });

    test('contains uppercase, lowercase, digits, and symbols', () {
      final password = PasswordGenerator.generateTemporaryPassword(length: 12);

      final hasUpper = password.contains(RegExp(r'[A-Z]'));
      final hasLower = password.contains(RegExp(r'[a-z]'));
      final hasDigit = password.contains(RegExp(r'[0-9]'));
      final hasSymbol = password.contains(RegExp(r'[!@#\$%^&*()_+\-=]'));

      expect(hasUpper, isTrue);
      expect(hasLower, isTrue);
      expect(hasDigit, isTrue);
      expect(hasSymbol, isTrue);
    });
  });
}
