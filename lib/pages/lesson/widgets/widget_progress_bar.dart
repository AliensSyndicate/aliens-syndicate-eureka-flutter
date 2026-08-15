import 'package:flutter/material.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_motion.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';

class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    required this.value,
    required this.progressColor,
    super.key,
  });
  final double value;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0);
    return Semantics(
      label: AppStrings.lessonProgress,
      value: '${(normalizedValue * 100).round()}%',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: normalizedValue),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : UiMotion.lessonProgressDuration,
          curve: UiMotion.lessonProgressCurve,
          builder: (context, animatedValue, child) => LinearProgressIndicator(
            value: animatedValue,
            minHeight: UiSize.lessonProgressHeight,
            color: progressColor,
            backgroundColor: UiColor.lessonProgressTrack,
            borderRadius: BorderRadius.circular(UiRadius.pill),
          ),
        ),
      ),
    );
  }
}
