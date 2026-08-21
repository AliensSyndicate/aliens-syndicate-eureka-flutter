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
        Text(
          '$subject - $title',
          style: UiText.small.copyWith(color: UiColor.textPrimary),
        ),
        const SizedBox(height: UiSpacing.xxs),
        Text(
          pageLabel,
          style: UiText.small.copyWith(color: UiColor.textSecondary),
        ),
      ],
    ),
  );
}
