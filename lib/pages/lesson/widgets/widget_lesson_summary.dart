import 'package:flutter/material.dart';

import '../../../app/components/app_button.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonSummary extends StatelessWidget {
  const LessonSummary({
    required this.questions,
    required this.resultFor,
    required this.primaryColor,
    required this.onRetry,
    super.key,
  });

  final List<Question> questions;
  final bool? Function(Question question) resultFor;
  final Color primaryColor;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final correctAnswers = questions
        .where((item) => resultFor(item) == true)
        .length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.activitiesSummary, style: UiText.h4),
          const SizedBox(height: UiSpacing.sm),
          Text(AppStrings.activitiesSummaryIntro, style: UiText.p),
          const SizedBox(height: UiSpacing.xs),
          Text(
            AppStrings.activitiesSummaryResult(
              correctAnswers,
              questions.length,
            ),
            style: UiText.h6,
          ),
          const SizedBox(height: UiSpacing.xl),
          ...questions.indexed.map((entry) {
            final position = entry.$1 + 1;
            final question = entry.$2;
            final result = resultFor(question);
            final color = switch (result) {
              true => UiColor.success,
              false => UiColor.error,
              null => UiColor.warning,
            };
            final status = switch (result) {
              true => AppStrings.activityCorrect,
              false => AppStrings.activityIncorrect,
              null => AppStrings.activityNotDone,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: UiSpacing.md),
              child: Semantics(
                label: AppStrings.activityItemSemantics(position, status),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: switch (result) {
                        true => UiIcon.correct(
                          size: UiSize.iconMd,
                          color: color,
                        ),
                        false => UiIcon.incorrect(
                          size: UiSize.iconMd,
                          color: color,
                        ),
                        null => UiIcon.timer(size: UiSize.iconMd, color: color),
                      },
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.activityItemSummary(position, status),
                            style: UiText.label.copyWith(color: color),
                          ),
                          const SizedBox(height: UiSpacing.xxs),
                          Text(question.prompt, style: UiText.p),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: UiSpacing.lg),
          AppButton(
            key: const ValueKey('lesson-summary-retry'),
            label: AppStrings.tryAgain,
            color: primaryColor,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
