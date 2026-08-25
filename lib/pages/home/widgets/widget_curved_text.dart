import 'dart:math' as math;
import 'package:flutter/material.dart';

class CurvedText extends StatelessWidget {
  const CurvedText({
    required this.text,
    required this.textStyle,
    required this.radius,
    this.letterSpacing = 1.0,
    this.isBottom = false,
    this.closingGap,
    super.key,
  });

  final String text;
  final TextStyle textStyle;
  final double radius;
  final double letterSpacing;
  final bool isBottom;
  final double? closingGap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _CurvedTextPainter(
        text: text,
        textStyle: textStyle,
        radius: radius,
        letterSpacing: letterSpacing,
        isBottom: isBottom,
        closingGap: closingGap,
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
    required this.isBottom,
    required this.closingGap,
  });

  final String text;
  final TextStyle textStyle;
  final double radius;
  final double letterSpacing;
  final bool isBottom;
  final double? closingGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty || radius <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final characters = _fittedCharacters();
    if (isBottom) characters.setAll(0, characters.reversed.toList());
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

    final startAngle = isBottom
        ? (math.pi / 2) - (totalAngle / 2)
        : (-math.pi / 2) - (totalAngle / 2);
    double currentAngle = startAngle;

    for (var i = 0; i < characters.length; i++) {
      final painter = letterPainters[i];
      final charAngle = letterAngles[i];
      final midAngle = currentAngle + (charAngle / 2);

      final x = center.dx + radius * math.cos(midAngle);
      final y = center.dy + radius * math.sin(midAngle);

      canvas.save();
      canvas.translate(x, y);
      final rotationAngle = isBottom
          ? midAngle - (math.pi / 2)
          : midAngle + (math.pi / 2);
      canvas.rotate(rotationAngle);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();

      currentAngle += charAngle;
    }
  }

  List<String> _fittedCharacters() {
    final characters = text.characters.toList();
    if (closingGap == null) return characters;

    final maxTextWidth = (2 * math.pi * radius) - closingGap!;
    final fullTextWidth = characters.fold<double>(
      0,
      (width, character) => width + _characterWidth(character),
    );
    if (fullTextWidth <= maxTextWidth) return characters;

    const ellipsis = ['.', '.', '.'];
    final ellipsisWidth = ellipsis.fold<double>(
      0,
      (width, character) => width + _characterWidth(character),
    );
    final availableWidth = math.max(0.0, maxTextWidth - ellipsisWidth);
    final fitted = <String>[];
    var fittedWidth = 0.0;
    for (final character in characters) {
      final characterWidth = _characterWidth(character);
      if (fittedWidth + characterWidth > availableWidth) break;
      fitted.add(character);
      fittedWidth += characterWidth;
    }
    return [...fitted, ...ellipsis];
  }

  double _characterWidth(String character) {
    final painter = TextPainter(
      text: TextSpan(text: character, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + letterSpacing;
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.textStyle != textStyle ||
      oldDelegate.radius != radius ||
      oldDelegate.letterSpacing != letterSpacing ||
      oldDelegate.isBottom != isBottom ||
      oldDelegate.closingGap != closingGap;
}
