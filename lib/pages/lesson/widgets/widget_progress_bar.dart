import 'package:flutter/material.dart';
import '../../../l10n/app_strings.dart';

class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({required this.value, super.key});
  final double value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: AppStrings.lessonProgress,
    value: '${(value * 100).round()}%',
    child: LinearProgressIndicator(
      value: value,
      minHeight: 10,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
