import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/ui_text.dart';
import 'widget_curved_text.dart';

class ActionPlanetButton extends StatefulWidget {
  const ActionPlanetButton({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.color,
    required this.onTap,
    this.animationIndex = 0,
    this.size = 80.0,
    this.separateTitleEnds = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final Color color;
  final VoidCallback onTap;
  final int animationIndex;
  final double size;
  final bool separateTitleEnds;

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
    final textRadius = (widget.size / 2) + 3.0;
    final displayTitle = widget.separateTitleEnds
        ? '${widget.title} ... '
        : widget.title;
    final textStyle = UiText.label.copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w800,
      color: widget.color,
      shadows: const [
        Shadow(color: Colors.black87, offset: Offset(0, 1), blurRadius: 1),
      ],
    );

    return Semantics(
      button: true,
      label: widget.subtitle.isEmpty
          ? widget.title
          : '${widget.title}, ${widget.subtitle}',
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
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  widget.imageAsset,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
                CurvedText(
                  text: displayTitle,
                  radius: textRadius,
                  letterSpacing: 1.0,
                  textStyle: textStyle,
                ),
                CurvedText(
                  text: widget.subtitle,
                  radius: textRadius,
                  letterSpacing: 1.0,
                  isBottom: true,
                  textStyle: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
