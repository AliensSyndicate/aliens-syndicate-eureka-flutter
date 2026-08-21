import 'package:flutter/material.dart';

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
    super.key,
  });

  final List<Question> questions;
  final bool? Function(Question question) resultFor;

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
            final correct = resultFor(question) == true;
            final color = correct ? UiColor.success : UiColor.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: UiSpacing.md),
              child: Semantics(
                label: correct
                    ? 'Atividade $position, correta'
                    : 'Atividade $position, incorreta',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: correct
                          ? UiIcon.correct(size: UiSize.iconMd, color: color)
                          : UiIcon.incorrect(size: UiSize.iconMd, color: color),
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atividade $position',
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
        ],
      ),
    );
  }
}
