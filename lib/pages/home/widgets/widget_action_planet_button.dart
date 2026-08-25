import 'package:flutter/material.dart';

import '../../../ui/ui_text.dart';
import 'widget_curved_text.dart';
import 'widget_planet_orbit_motion.dart';

class ActionPlanetButton extends StatelessWidget {
  const ActionPlanetButton({
    required this.semanticLabel,
    required this.label,
    required this.labelColor,
    required this.imageAsset,
    required this.onTap,
    this.animationIndex = 0,
    this.size = 80.0,
    this.imageSize,
    this.textRadiusOffset = 10.0,
    super.key,
  });

  final String semanticLabel;
  final String label;
  final Color labelColor;
  final String imageAsset;
  final VoidCallback onTap;
  final int animationIndex;
  final double size;
  final double? imageSize;
  final double textRadiusOffset;

  @override
  Widget build(BuildContext context) {
    final textRadius = (size / 2) + textRadiusOffset;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: PlanetOrbitMotion(
        animationIndex: animationIndex,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  imageAsset,
                  width: imageSize ?? size,
                  height: imageSize ?? size,
                  fit: BoxFit.contain,
                ),
                CurvedText(
                  text: label,
                  radius: textRadius,
                  letterSpacing: 1.0,
                  textStyle: UiText.label.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                    color: labelColor,
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
      ),
    );
  }
}
