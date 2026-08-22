import 'package:flutter/animation.dart';

abstract final class UiMotion {
  static const screenTransitionDuration = Duration(milliseconds: 300);
  static const screenTransitionCurve = Curves.easeOutCubic;
  static const screenTransitionOffset = Offset(0.08, 0);
  static const lessonActivityDuration = Duration(milliseconds: 420);
  static const lessonActivityCurve = Curves.easeOutCubic;
  static const lessonActivitySlideOffset = 80.0;
  static const campfireFlickerDuration = Duration(milliseconds: 1200);
}
