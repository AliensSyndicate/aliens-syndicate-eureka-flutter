import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

/// Apresenta a explicação que ocupa a primeira página de uma aula.
class ExerciseContent extends StatelessWidget {
  const ExerciseContent({
    required this.title,
    required this.description,
    required this.primaryColor,
    this.notice,
    super.key,
  });

  final String title;
  final String description;
  final Color primaryColor;
  final String? notice;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: UiText.h5.copyWith(color: primaryColor)),
      const SizedBox(height: UiSpacing.md),
      Text(description, style: UiText.p),
      if (notice != null) ...[
        const SizedBox(height: UiSpacing.xxl),
        Text(
          notice!,
          textAlign: TextAlign.center,
          style: UiText.p.copyWith(color: UiColor.textSecondary),
        ),
      ],
    ],
  );
}
