import 'dart:math';

/// Cryptographically secure temporary password generator.
///
/// Ensures at least 1 uppercase, 1 lowercase, 1 digit, and 1 symbol,
/// followed by a Fisher-Yates shuffle.
class PasswordGenerator {
  const PasswordGenerator._();

  static const String _uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // omit confusing I, O
  static const String _lowercase = 'abcdefghijkmnopqrstuvwxyz'; // omit confusing l
  static const String _digits = '23456789'; // omit 0, 1
  static const String _symbols = '!@#\$%^&*()_+-=';
  static const String _allChars = '$_uppercase$_lowercase$_digits$_symbols';

  /// Generates a temporary password of the specified [length] (minimum 8).
  static String generateTemporaryPassword({int length = 12}) {
    if (length < 8) {
      throw ArgumentError('Password length must be at least 8 characters.');
    }

    final random = Random.secure();
    final chars = <String>[
      _uppercase[random.nextInt(_uppercase.length)],
      _lowercase[random.nextInt(_lowercase.length)],
      _digits[random.nextInt(_digits.length)],
      _symbols[random.nextInt(_symbols.length)],
    ];

    for (var i = chars.length; i < length; i++) {
      chars.add(_allChars[random.nextInt(_allChars.length)]);
    }

    // Fisher-Yates shuffle
    for (var i = chars.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = chars[i];
      chars[i] = chars[j];
      chars[j] = temp;
    }

    return chars.join();
  }
}
