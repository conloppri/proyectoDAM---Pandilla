import 'package:flutter/material.dart';

class PaperBackground extends StatelessWidget {
  final Color lineColor;
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
class _PaperPainter extends CustomPainter {
  final Color color;
  final double lineSpacing;

  _PaperPainter(this.color, this.lineSpacing);

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}