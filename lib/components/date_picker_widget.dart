import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget selector de fecha.
///
/// Muestra un botón que abre un selector de fecha nativo y permite
/// al usuario elegir una fecha dentro de un rango definido.
/// La fecha seleccionada se devuelve al widget padre mediante [onDateSelected].
class DatePickerWidget extends StatefulWidget {
  /// Fecha inicialmente seleccionada.
  final DateTime selectedDate;

  /// Texto que acompaña al selector (etiqueta).
  final String label;

  /// Fecha mínima permitida en el selector.
  final DateTime firstDate;

  /// Fecha máxima permitida en el selector.
  final DateTime lastDate;

  /// Callback que se ejecuta cuando el usuario selecciona una nueva fecha.
  final Function onDateSelected;

  /// Color del botón que muestra la fecha.
  final Color buttonColor;

  /// Estilo del texto de la etiqueta y del botón.
  final TextStyle labelStyle;

  const DatePickerWidget({
    super.key,
    required this.label,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.buttonColor = Colors.white,
    this.labelStyle = const TextStyle(),
    required this.selectedDate,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

/// Estado del widget [DatePickerWidget].
///
/// Gestiona la fecha seleccionada internamente y sincroniza cambios
/// con el widget padre cuando se actualiza la propiedad [selectedDate].
class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate = DateTime.now();

  /// Se ejecuta cuando el widget padre actualiza sus propiedades.
  ///
  /// Se usa para sincronizar la fecha interna si cambia desde fuera.
  @override
  void didUpdateWidget(covariant DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  /// Inicializa la fecha seleccionada con la proporcionada por el padre.
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  /// Construye la interfaz del selector de fecha.
  ///
  /// Muestra una etiqueta y un botón que abre el selector de fecha nativo.
  /// Al seleccionar una fecha:
  /// - Se actualiza el estado interno.
  /// - Se notifica al widget padre mediante [widget.onDateSelected].
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Etiqueta descriptiva del campo de fecha
        Expanded(child: Text(widget.label, style: widget.labelStyle)),
        const SizedBox(width: 20),

        /// Botón que abre el selector de fecha
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                initialDate: widget.selectedDate,
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
                widget.onDateSelected(_selectedDate);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor),
            child: Text(
              DateFormat("dd/MM/yyyy").format(_selectedDate),
              style: widget.labelStyle,
            ),
          ),
        ),
      ],
    );
  }
}
