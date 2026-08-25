import 'package:flutter/material.dart';

import '../../../models/content/model_content_manifest.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_text.dart';
import 'widget_curved_text.dart';
import 'widget_planet_orbit_motion.dart';

class PlanetButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textRadius = (size / 2) + 10.0;
    final subjectColor = UiColor.forSubject(subject.type);

    return PlanetOrbitMotion(
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
                'assets/images/${subject.type.name}.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
              CurvedText(
                text: subject.title,
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
              if (progressText != null)
                CurvedText(
                  text: progressText!,
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
