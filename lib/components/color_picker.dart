import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class ColorPicker extends StatefulWidget {
  final List colors = ["pink", "purple", "blue", "green", "yellow"];
  final String selectedColor;
  final Function(String) onColorSelected;
  ColorPicker({super.key ,required this.onColorSelected, required this.selectedColor});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int _selectedColorIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedColorIndex = widget.colors.indexOf(widget.selectedColor);
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedColorIndex = 0;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.pink_note,
          shape: CircleBorder(),
          child: _selectedColorIndex == 0
              ? Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedColorIndex = 1;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.purple_note,
          shape: CircleBorder(),
          child: _selectedColorIndex == 1
              ? Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedColorIndex = 2;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.blue_note,
          shape: CircleBorder(),
          child: _selectedColorIndex == 2
              ? Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedColorIndex = 3;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.green_note,
          shape: CircleBorder(),
          child: _selectedColorIndex == 3
              ? Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedColorIndex = 4;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.yellow_note,
          shape: CircleBorder(),
          child: _selectedColorIndex == 4
              ? Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
