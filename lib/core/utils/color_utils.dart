import 'package:flutter/material.dart';

/// Preset color entry for saree / textile materials.
class PresetColor {
  const PresetColor({
    required this.name,
    required this.color,
    required this.hex,
  });

  final String name;
  final Color color;
  final String hex;
}

class ColorUtils {
  ColorUtils._();

  /// Parse hex color string (e.g. "#FF0000", "FF0000", "#FFF", "0xFF0000").
  static Color? fromHex(String? hexString) {
    if (hexString == null) return null;
    var hex = hexString.trim().replaceAll('#', '');
    if (hex.isEmpty) return null;
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  /// Converts a [Color] to uppercase hex string (e.g. "#E53935").
  static String toHex(Color color, {bool leadingHashSign = true}) {
    final a = (color.a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final r = (color.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');

    final hex = '$a$r$g$b'.toUpperCase();
    final rgb = hex.substring(2);
    return leadingHashSign ? '#$rgb' : rgb;
  }

  /// Returns true if [color] is bright/light, useful for contrasting text/borders.
  static bool isLightColor(Color color) {
    // Relative luminance
    return color.computeLuminance() > 0.65;
  }

  /// Resolves a color from either explicit [colorCode] (hex) or [colorName] fallback.
  static Color? resolveColor({String? colorCode, String? colorName}) {
    final fromCode = fromHex(colorCode);
    if (fromCode != null) return fromCode;
    if (colorName != null && colorName.trim().isNotEmpty) {
      return fallbackColorFromName(colorName.trim());
    }
    return null;
  }

  /// Natural fallback colors for traditional saree / fabric color names.
  static Color? fallbackColorFromName(String name) {
    final q = name.toLowerCase().trim();

    if (q.contains('blood red') || q.contains('crimson')) {
      return const Color(0xFFC62828);
    }
    if (q.contains('maroon') || q.contains('wine')) {
      return const Color(0xFF800020);
    }
    if (q.contains('red') || q.contains('lal')) {
      return const Color(0xFFE53935);
    }
    if (q.contains('rani') || q.contains('hot pink')) {
      return const Color(0xFFE91E63);
    }
    if (q.contains('baby pink') || q.contains('light pink')) {
      return const Color(0xFFF8BBD0);
    }
    if (q.contains('pink') || q.contains('gulabi')) {
      return const Color(0xFFEC407A);
    }
    if (q.contains('navy') || q.contains('midnight')) {
      return const Color(0xFF0D47A1);
    }
    if (q.contains('royal blue')) {
      return const Color(0xFF1565C0);
    }
    if (q.contains('sky blue') || q.contains('firozi')) {
      return const Color(0xFF03A9F4);
    }
    if (q.contains('blue') || q.contains('neela')) {
      return const Color(0xFF1976D2);
    }
    if (q.contains('cyan')) {
      return const Color(0xFF00BCD4);
    }
    if (q.contains('peacock') || q.contains('rama')) {
      return const Color(0xFF00897B);
    }
    if (q.contains('teal')) {
      return const Color(0xFF00796B);
    }
    if (q.contains('bottle green') || q.contains('dark green')) {
      return const Color(0xFF1B5E20);
    }
    if (q.contains('emerald')) {
      return const Color(0xFF2E7D32);
    }
    if (q.contains('pista') || q.contains('mint')) {
      return const Color(0xFFA5D6A7);
    }
    if (q.contains('mehendi') || q.contains('olive')) {
      return const Color(0xFF558B2F);
    }
    if (q.contains('green') || q.contains('hara')) {
      return const Color(0xFF388E3C);
    }
    if (q.contains('mustard')) {
      return const Color(0xFFF9A825);
    }
    if (q.contains('gold') || q.contains('golden')) {
      return const Color(0xFFFFD700);
    }
    if (q.contains('yellow') || q.contains('peela')) {
      return const Color(0xFFFBC02D);
    }
    if (q.contains('kesari') || q.contains('saffron')) {
      return const Color(0xFFFF6F00);
    }
    if (q.contains('orange') || q.contains('narangi')) {
      return const Color(0xFFF57C00);
    }
    if (q.contains('peach')) {
      return const Color(0xFFFFAB91);
    }
    if (q.contains('violet')) {
      return const Color(0xFF7E57C2);
    }
    if (q.contains('purple') || q.contains('baingani')) {
      return const Color(0xFF8E24AA);
    }
    if (q.contains('magenta')) {
      return const Color(0xFFD81B60);
    }
    if (q.contains('lavender')) {
      return const Color(0xFFCE93D8);
    }
    if (q.contains('black') || q.contains('kala')) {
      return const Color(0xFF212121);
    }
    if (q.contains('white') || q.contains('safed')) {
      return const Color(0xFFFFFFFF);
    }
    if (q.contains('cream') || q.contains('off white')) {
      return const Color(0xFFFFF9C4);
    }
    if (q.contains('beige') || q.contains('chiku')) {
      return const Color(0xFFD7CCC8);
    }
    if (q.contains('brown') || q.contains('coffee')) {
      return const Color(0xFF5D4037);
    }
    if (q.contains('silver')) {
      return const Color(0xFFB0BEC5);
    }
    if (q.contains('grey') || q.contains('gray')) {
      return const Color(0xFF757575);
    }

    return null;
  }

  /// Curated list of popular saree and textile shades.
  static const List<PresetColor> presetSareeColors = [
    // Reds & Maroons
    PresetColor(name: 'Ruby Red', color: Color(0xFFC62828), hex: '#C62828'),
    PresetColor(name: 'Bright Red', color: Color(0xFFE53935), hex: '#E53935'),
    PresetColor(name: 'Deep Maroon', color: Color(0xFF800020), hex: '#800020'),
    PresetColor(name: 'Wine', color: Color(0xFF722F37), hex: '#722F37'),

    // Pinks
    PresetColor(name: 'Rani Pink', color: Color(0xFFE91E63), hex: '#E91E63'),
    PresetColor(name: 'Rose Pink', color: Color(0xFFF06292), hex: '#F06292'),
    PresetColor(name: 'Baby Pink', color: Color(0xFFF8BBD0), hex: '#F8BBD0'),
    PresetColor(name: 'Peach', color: Color(0xFFFFAB91), hex: '#FFAB91'),

    // Blues
    PresetColor(name: 'Royal Blue', color: Color(0xFF1565C0), hex: '#1565C0'),
    PresetColor(name: 'Navy Blue', color: Color(0xFF0D47A1), hex: '#0D47A1'),
    PresetColor(name: 'Sky Blue', color: Color(0xFF03A9F4), hex: '#03A9F4'),
    PresetColor(name: 'Firozi (Cyan)', color: Color(0xFF00ACC1), hex: '#00ACC1'),

    // Greens
    PresetColor(name: 'Peacock Teal', color: Color(0xFF00796B), hex: '#00796B'),
    PresetColor(name: 'Emerald Green', color: Color(0xFF2E7D32), hex: '#2E7D32'),
    PresetColor(name: 'Bottle Green', color: Color(0xFF1B5E20), hex: '#1B5E20'),
    PresetColor(name: 'Mehendi Green', color: Color(0xFF558B2F), hex: '#558B2F'),
    PresetColor(name: 'Pista Green', color: Color(0xFFA5D6A7), hex: '#A5D6A7'),
    PresetColor(name: 'Rama Green', color: Color(0xFF00897B), hex: '#00897B'),

    // Yellows & Oranges
    PresetColor(name: 'Mustard Yellow', color: Color(0xFFF9A825), hex: '#F9A825'),
    PresetColor(name: 'Bright Yellow', color: Color(0xFFFDD835), hex: '#FDD835'),
    PresetColor(name: 'Golden Yellow', color: Color(0xFFFFD700), hex: '#FFD700'),
    PresetColor(name: 'Saffron / Kesari', color: Color(0xFFFF6F00), hex: '#FF6F00'),
    PresetColor(name: 'Orange', color: Color(0xFFF57C00), hex: '#F57C00'),

    // Purples
    PresetColor(name: 'Deep Purple', color: Color(0xFF6A1B9A), hex: '#6A1B9A'),
    PresetColor(name: 'Royal Violet', color: Color(0xFF4A148C), hex: '#4A148C'),
    PresetColor(name: 'Lavender', color: Color(0xFFBA68C8), hex: '#BA68C8'),
    PresetColor(name: 'Magenta', color: Color(0xFFC2185B), hex: '#C2185B'),

    // Neutrals
    PresetColor(name: 'Black', color: Color(0xFF212121), hex: '#212121'),
    PresetColor(name: 'Pure White', color: Color(0xFFFFFFFF), hex: '#FFFFFF'),
    PresetColor(name: 'Cream / Off-White', color: Color(0xFFFFF9C4), hex: '#FFF9C4'),
    PresetColor(name: 'Beige / Chiku', color: Color(0xFFD7CCC8), hex: '#D7CCC8'),
    PresetColor(name: 'Coffee Brown', color: Color(0xFF4E342E), hex: '#4E342E'),
    PresetColor(name: 'Silver / Slate', color: Color(0xFF90A4AE), hex: '#90A4AE'),
  ];
}
