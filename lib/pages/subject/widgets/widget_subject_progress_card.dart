import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({
    required this.completed,
    required this.total,
    required this.color,
    super.key,
  });

  final int completed;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      key: const ValueKey('subject-progress-card'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [Text(AppStrings.subjectProgressTitle, style: UiText.h5)],
        ),
        Text(
          AppStrings.completedLessonsRatio(completed, total),
          style: UiText.p.copyWith(color: UiColor.textSecondary),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                key: const ValueKey('subject-progress-bar'),
                height: UiCard.progressTagHeight / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UiCard.radius),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: UiColor.textPrimary.withValues(alpha: .14),
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: UiSpacing.sm),
            Text(
              AppStrings.percent((progress * 100).round()),
              style: UiText.h6.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}
