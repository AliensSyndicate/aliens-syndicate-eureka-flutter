import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_text.dart';
import 'widget_curved_text.dart';

class PlanetButton extends StatefulWidget {
  const PlanetButton({
    required this.subject,
    required this.size,
    required this.onTap,
    this.progressText,
    this.animationIndex = 0,
    super.key,
  });

  final SubjectContentManifest subject;
  final double size;
  final VoidCallback onTap;
  final String? progressText;
  final int animationIndex;

  @override
  State<PlanetButton> createState() => _PlanetButtonState();
}

class _PlanetButtonState extends State<PlanetButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final durationMs = 24000 + (widget.animationIndex * 1800) % 6000;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textRadius = (widget.size / 2) + 6.0;
    final subjectColor = UiColor.forSubject(widget.subject.type);
    final idx = widget.animationIndex;
    final phase = idx * (2 * math.pi / 5.0);
    final amplitudeX = 3.0 + (idx % 2) * 1.5;
    final amplitudeY = 4.0 + ((idx + 1) % 3) * 1.5;
    final directionX = idx.isOdd ? -1.0 : 1.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        final offsetX =
            directionX * amplitudeX * math.sin(t + phase) +
            (amplitudeX * 0.25 * math.sin(2 * t + phase));
        final offsetY =
            amplitudeY * math.cos(t + phase) +
            (amplitudeY * 0.2 * math.cos(2 * t + phase));

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/${widget.subject.type.name}.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
              CurvedText(
                text: widget.subject.title,
                radius: textRadius,
                letterSpacing: 2.0,
                textStyle: UiText.h5.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: subjectColor,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              if (widget.progressText != null)
                CurvedText(
                  text: widget.progressText!,
                  radius: textRadius,
                  letterSpacing: 2.0,
                  isBottom: true,
                  textStyle: UiText.h5.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: subjectColor,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        offset: Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
