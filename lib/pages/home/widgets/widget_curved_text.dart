import 'dart:math' as math;
import 'package:flutter/material.dart';

class CurvedText extends StatelessWidget {
  const CurvedText({
    required this.text,
    required this.textStyle,
    required this.radius,
    this.letterSpacing = 1.0,
    super.key,
  });

  final String text;
  final TextStyle textStyle;
  final double radius;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _CurvedTextPainter(
        text: text,
        textStyle: textStyle,
        radius: radius,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

class _CurvedTextPainter extends CustomPainter {
  _CurvedTextPainter({
    required this.text,
    required this.textStyle,
    required this.radius,
    required this.letterSpacing,
  });

  final String text;
  final TextStyle textStyle;
  final double radius;
  final double letterSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty || radius <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final characters = text.characters.toList();
    final letterPainters = <TextPainter>[];
    final letterAngles = <double>[];
    double totalAngle = 0;

    for (final char in characters) {
      final painter = TextPainter(
        text: TextSpan(text: char, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      letterPainters.add(painter);
      final charWidth = painter.width + letterSpacing;
      final angle = charWidth / radius;
      letterAngles.add(angle);
      totalAngle += angle;
    }

    double currentAngle = -math.pi / 2 - (totalAngle / 2);

    for (var i = 0; i < characters.length; i++) {
      final painter = letterPainters[i];
      final charAngle = letterAngles[i];
      final midAngle = currentAngle + (charAngle / 2);

      final x = center.dx + radius * math.cos(midAngle);
      final y = center.dy + radius * math.sin(midAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(midAngle + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();

      currentAngle += charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.textStyle != textStyle ||
      oldDelegate.radius != radius ||
      oldDelegate.letterSpacing != letterSpacing;
}
