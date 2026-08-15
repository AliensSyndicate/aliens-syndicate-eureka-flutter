import 'package:flutter/material.dart';

import '../../../ui/ui_spacing.dart';

class LessonDescription extends StatelessWidget {
  const LessonDescription({
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
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: primaryColor),
      ),
      const SizedBox(height: UiSpacing.md),
      Text(description, style: Theme.of(context).textTheme.bodyLarge),
      if (notice != null) ...[
        const SizedBox(height: UiSpacing.xxl),
        Text(notice!, textAlign: TextAlign.center),
      ],
    ],
  );
}
