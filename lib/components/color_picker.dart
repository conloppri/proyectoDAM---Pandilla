import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Widget selector de colores para notas.
///
/// Permite al usuario elegir un color entre un conjunto predefinido.
/// El color seleccionado se comunica al widget padre mediante el callback
/// [onColorSelected], y se muestra visualmente como activo en la interfaz.
class ColorPicker extends StatefulWidget {
  /// Lista interna de colores disponibles
  final List colors = ["pink", "purple", "blue", "green", "yellow"];

  /// Color actualmente seleccionado.
  final String selectedColor;

  /// Callback que se ejecuta cuando el usuario selecciona un color.
  final Function(String) onColorSelected;

  ColorPicker({super.key ,required this.onColorSelected, required this.selectedColor});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

/// Estado del widget [ColorPicker].
///
/// Gestiona el índice del color seleccionado y sincroniza la selección
/// con el widget padre mediante callbacks.
class _ColorPickerState extends State<ColorPicker> {

  /// Índice del color actualmente seleccionado.
  int _selectedColorIndex = 0;

  /// Inicializa el estado del widget.
  ///
  /// Se ejecuta una única vez cuando el widget se inserta en el árbol.
  /// En este caso, calcula el índice del color seleccionado inicialmente
  /// a partir del valor recibido.
  @override
  void initState() {
    super.initState();
    _selectedColorIndex = widget.colors.indexOf(widget.selectedColor);
  }

  /// Construye la interfaz del selector de colores.
  ///
  /// Muestra una fila de botones circulares, cada uno representando un color.
  /// Cuando un color es seleccionado:
  /// - Se actualiza el estado interno .
  /// - Se notifica al widget padre mediante el callback [widget.onColorSelected].
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /// Botón de selección de color rosa
        FloatingActionButton(
          heroTag: "fab-pink",
          onPressed: () {
            setState(() {
              _selectedColorIndex = 0;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.pinkNote,
          shape: const CircleBorder(),
          child: _selectedColorIndex == 0
              ? const Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        /// Botón de selección de color morado
        FloatingActionButton(
          heroTag: "fab-purple",
          onPressed: () {
            setState(() {
              _selectedColorIndex = 1;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.purpleNote,
          shape: const CircleBorder(),
          child: _selectedColorIndex == 1
              ? const Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        /// Botón de selección de color azul
        FloatingActionButton(
          heroTag: "fab-blue",
          onPressed: () {
            setState(() {
              _selectedColorIndex = 2;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.blueNote,
          shape: const CircleBorder(),
          child: _selectedColorIndex == 2
              ? const Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
        /// Botón de selección de color verde
        FloatingActionButton(
          heroTag: "fab-green",
          onPressed: () {
            setState(() {
              _selectedColorIndex = 3;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.greenNote,
          shape: const CircleBorder(),
          child: _selectedColorIndex == 3
              ? const Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),

        /// Botón de selección de color amarillo
        FloatingActionButton(
          heroTag: "fab-yellow",
          onPressed: () {
            setState(() {
              _selectedColorIndex = 4;
              widget.onColorSelected(widget.colors[_selectedColorIndex]);
            });
          },
          backgroundColor: AppColors.yellowNote,
          shape: const CircleBorder(),
          child: _selectedColorIndex == 4
              ? const Icon(Icons.close, size: 30, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
