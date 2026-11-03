import 'package:flutter/material.dart';
import 'package:saree_sutra/core/utils/color_utils.dart';
import 'package:saree_sutra/core/widgets/product_color_dot.dart';

/// Shows an interactive color picker dialog designed for textile & saree colors.
///
/// Returns:
/// - A valid hex string like `"#E53935"` when a color is chosen and applied.
/// - `""` (empty string) when user explicitly chooses "Clear / No Color".
/// - `null` when user cancels or dismisses the dialog.
Future<String?> showColorPickerDialog(
  BuildContext context, {
  String? initialColorCode,
  String? colorName,
}) async {
  return showDialog<String?>(
    context: context,
    builder: (ctx) => _ColorPickerDialog(
      initialColorCode: initialColorCode,
      colorName: colorName,
    ),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({
    this.initialColorCode,
    this.colorName,
  });

  final String? initialColorCode;
  final String? colorName;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late String? _selectedHex;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selectedHex = widget.initialColorCode?.trim();
    if (_selectedHex != null && !_selectedHex!.startsWith('#')) {
      _selectedHex = '#$_selectedHex';
    }
    _hexController = TextEditingController(text: _selectedHex ?? '');
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _onSelectPreset(PresetColor preset) {
    setState(() {
      _selectedHex = preset.hex;
      _hexController.text = preset.hex;
    });
  }

  void _onHexChanged(String val) {
    final trimmed = val.trim();
    final parsed = ColorUtils.fromHex(trimmed);
    if (parsed != null) {
      setState(() {
        _selectedHex = ColorUtils.toHex(parsed);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentColor = ColorUtils.fromHex(_selectedHex);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Choose Color (Optional)'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.colorName != null && widget.colorName!.isNotEmpty) ...[
                Text(
                  'Color for: ${widget.colorName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Current color preview banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentColor ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: currentColor != null
                        ? (ColorUtils.isLightColor(currentColor)
                            ? Colors.black26
                            : Colors.white24)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: currentColor ?? Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                      alignment: Alignment.center,
                      child: currentColor == null
                          ? const Icon(Icons.block, size: 20, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentColor != null
                                ? 'Selected Color: $_selectedHex'
                                : 'No Color Selected (Default)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: currentColor != null
                                  ? (ColorUtils.isLightColor(currentColor)
                                      ? Colors.black87
                                      : Colors.white)
                                  : Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentColor != null
                                ? 'This color will display as a swatch throughout the ERP'
                                : 'Select a preset below or enter a custom hex code',
                            style: TextStyle(
                              fontSize: 11,
                              color: currentColor != null
                                  ? (ColorUtils.isLightColor(currentColor)
                                      ? Colors.black54
                                      : Colors.white70)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (currentColor != null)
                      IconButton(
                        tooltip: 'Clear Color',
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: ColorUtils.isLightColor(currentColor)
                              ? Colors.black87
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedHex = null;
                            _hexController.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Preset Saree Palettes
              Text(
                'Popular Saree & Textile Shades:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ColorUtils.presetSareeColors.map((preset) {
                  final isSelected =
                      _selectedHex?.toUpperCase() == preset.hex.toUpperCase();
                  final isLight = ColorUtils.isLightColor(preset.color);

                  return InkWell(
                    onTap: () => _onSelectPreset(preset),
                    borderRadius: BorderRadius.circular(20),
                    child: Tooltip(
                      message: '${preset.name} (${preset.hex})',
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: preset.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isLight ? Colors.black26 : Colors.transparent),
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: isLight ? Colors.black87 : Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Custom Hex Input
              Text(
                'Custom Hex Color:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      decoration: InputDecoration(
                        hintText: '#E53935 or FF0000',
                        isDense: true,
                        prefixIcon: const Icon(Icons.tag, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: _onHexChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (currentColor != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear Color'),
          onPressed: () {
            Navigator.of(context).pop('');
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedHex ?? '');
          },
          child: const Text('Set Color'),
        ),
      ],
    );
  }
}

/// A compact, interactive form field to pick and display an optional color swatch.
class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    required this.colorCode,
    required this.onColorChanged,
    this.colorName,
    this.label = 'Product Color (Optional)',
  });

  final String? colorCode;
  final ValueChanged<String?> onColorChanged;
  final String? colorName;
  final String label;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showColorPickerDialog(
      context,
      initialColorCode: colorCode,
      colorName: colorName,
    );
    if (result != null) {
      onColorChanged(result.isEmpty ? null : result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasColor = colorCode != null && colorCode!.trim().isNotEmpty;

    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasColor
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.grey.shade400,
          ),
          color: hasColor
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
              : null,
        ),
        child: Row(
          children: [
            ProductColorDot(
              colorCode: colorCode,
              colorName: colorName,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hasColor
                        ? '${colorCode!.toUpperCase()} (Tap to change)'
                        : 'No color selected (Tap to choose)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasColor ? FontWeight.bold : FontWeight.normal,
                      color: hasColor
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasColor)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Clear Color',
                onPressed: () => onColorChanged(null),
              )
            else
              Icon(
                Icons.palette_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
