import 'package:flutter/material.dart';
import 'package:saree_sutra/core/utils/color_utils.dart';

/// Renders a circular color swatch indicator for a product SKU.
///
/// Automatically resolves color from [colorCode] (hex) or [colorName] (fallback keyword).
/// If no color can be resolved, can optionally show a fallback letter or icon.
class ProductColorDot extends StatelessWidget {
  const ProductColorDot({
    super.key,
    this.colorCode,
    this.colorName,
    this.size = 14,
    this.showBorder = true,
    this.margin,
    this.tooltip,
  });

  final String? colorCode;
  final String? colorName;
  final double size;
  final bool showBorder;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.resolveColor(
      colorCode: colorCode,
      colorName: colorName,
    );

    if (color == null) {
      // If colorName has at least one character, show a clean initial badge
      if (colorName != null && colorName!.trim().isNotEmpty) {
        return Container(
          width: size,
          height: size,
          margin: margin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            colorName!.trim()[0].toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final isLight = ColorUtils.isLightColor(color);

    Widget dot = Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.35),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    final tip = tooltip ?? colorName ?? colorCode;
    if (tip != null && tip.isNotEmpty) {
      dot = Tooltip(
        message: tip,
        child: dot,
      );
    }

    return dot;
  }
}
