import 'package:flutter/material.dart';

/// Widget que dibuja un fondo tipo papel con líneas horizontales.
///
/// Se utiliza como fondo decorativo para simular hojas de cuaderno.
/// Las líneas se dibujan con un espaciado configurable y una opacidad baja.
class PaperBackground extends StatelessWidget {
  /// Color de las líneas del papel.
  final Color lineColor;

  /// Espaciado vertical entre cada línea.
  final double lineSpacing;

  const PaperBackground({super.key, this.lineColor = Colors.black, required this.lineSpacing});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperPainter(lineColor, lineSpacing),
      child: Container(),
    );
  }
}

/// Painter encargado de dibujar las líneas del fondo tipo papel.
class _PaperPainter extends CustomPainter {
  /// Color de las líneas.
  final Color color;

  /// Separación entre líneas horizontales.
  final double lineSpacing;

  _PaperPainter(this.color, this.lineSpacing);

  /// Dibuja las líneas horizontales sobre el canvas.
  ///
  /// Recorre toda la altura del widget y pinta líneas separadas
  /// según [lineSpacing].
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// Indica que el painter no necesita repintarse
  /// porque es completamente estático.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}