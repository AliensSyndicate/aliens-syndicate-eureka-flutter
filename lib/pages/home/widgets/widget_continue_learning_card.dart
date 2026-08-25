import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../ui/ui_color.dart';
import 'widget_action_planet_button.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    required this.lesson,
    required this.onTap,
    this.width = 80.0,
    this.height = 80.0,
    super.key,
  });

  final Lesson lesson;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ActionPlanetButton(
        semanticLabel: '${AppStrings.continueWhereStopped}, ${lesson.title}',
        label: AppStrings.continueWhereStopped,
        labelColor: UiColor.continueBorder,
        imageAsset: 'assets/images/continue.png',
        animationIndex: 2,
        onTap: onTap,
      ),
    );
  }
}
