import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSelector extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final String title;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.title,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor;
  }

  void _onColorChanged(Color color) {
    setState(() {
      _currentColor = color;
    });
    widget.onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) {
    final presetColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.grey,
    ];

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(widget.title),
          const SizedBox(height: 8),
        ],

        // プリセット色
        Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: presetColors.map((color) {
              final isSelected = _currentColor == color;
              return GestureDetector(
                onTap: () => _onColorChanged(color),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 16,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // カラーピッカー
        ColorPicker(
          pickerColor: _currentColor,
          onColorChanged: _onColorChanged,
          enableAlpha: false,
          labelTypes: const [],
          pickerAreaHeightPercent: 0.8,
          portraitOnly: true,
        ),
      ],
    ),
  );
  }
}
