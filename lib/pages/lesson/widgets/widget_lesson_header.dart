import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonHeader extends StatelessWidget {
  const LessonHeader({
    required this.subject,
    required this.title,
    required this.pageLabel,
    required this.subjectColor,
    super.key,
  });
  final String subject;
  final String title;
  final String pageLabel;
  final Color subjectColor;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subject, style: UiText.label.copyWith(color: subjectColor)),
        const SizedBox(height: UiSpacing.xxs),
        Text(title, style: UiText.h6),
        const SizedBox(height: UiSpacing.xxs),
        Text(
          pageLabel,
          style: UiText.label.copyWith(color: UiColor.textSecondary),
        ),
      ],
    ),
  );
}
