import 'dart:math' as math;

import 'package:flutter/material.dart';

class ActionPlanetButton extends StatefulWidget {
  const ActionPlanetButton({
    required this.semanticLabel,
    required this.imageAsset,
    required this.onTap,
    this.animationIndex = 0,
    this.size = 80.0,
    super.key,
  });

  final String semanticLabel;
  final String imageAsset;
  final VoidCallback onTap;
  final int animationIndex;
  final double size;

  @override
  State<ActionPlanetButton> createState() => _ActionPlanetButtonState();
}

class _ActionPlanetButtonState extends State<ActionPlanetButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 22000 + widget.animationIndex * 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = widget.animationIndex * math.pi / 3;
          final angle = _controller.value * 2 * math.pi;
          return Transform.translate(
            offset: Offset(
              2.0 * math.sin(angle + phase),
              3.0 * math.cos(angle + phase),
            ),
            child: child,
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Image.asset(
              widget.imageAsset,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
