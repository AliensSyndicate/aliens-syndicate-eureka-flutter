import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlanetOrbitMotion extends StatefulWidget {
  const PlanetOrbitMotion({
    required this.animationIndex,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final int animationIndex;
  final Widget child;
  final bool enabled;

  @override
  State<PlanetOrbitMotion> createState() => _PlanetOrbitMotionState();
}

class _PlanetOrbitMotionState extends State<PlanetOrbitMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final durationMs = 24000 + (widget.animationIndex * 1800) % 6000;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PlanetOrbitMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled == oldWidget.enabled) return;
    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final index = widget.animationIndex;
    final phase = index * (2 * math.pi / 5.0);
    final amplitudeX = 3.0 + (index % 2) * 1.5;
    final amplitudeY = 4.0 + ((index + 1) % 3) * 1.5;
    final directionX = index.isOdd ? -1.0 : 1.0;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;
        final offsetX =
            directionX * amplitudeX * math.sin(angle + phase) +
            (amplitudeX * 0.25 * math.sin(2 * angle + phase));
        final offsetY =
            amplitudeY * math.cos(angle + phase) +
            (amplitudeY * 0.2 * math.cos(2 * angle + phase));

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: child,
        );
      },
    );
  }
}
