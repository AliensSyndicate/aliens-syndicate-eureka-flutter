import 'package:flutter/animation.dart';

abstract final class UiMotion {
  static const lessonProgressDuration = Duration(milliseconds: 350);
  static const lessonProgressCurve = Curves.easeOutCubic;
  static const lessonActivityDuration = Duration(milliseconds: 420);
  static const lessonActivityCurve = Curves.easeOutCubic;
  static const lessonActivitySlideOffset = 80.0;
}
