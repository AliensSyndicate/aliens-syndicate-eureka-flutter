import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';

import '../../../app/components/app_text_field.dart';
import '../../../enums/question_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import 'widget_question_option.dart';

enum LessonActivityStatus { active, answeredCorrect, answeredIncorrect }

class LessonActivity extends StatelessWidget {
  const LessonActivity({
    required this.question,
    required this.position,
    required this.total,
    required this.primaryColor,
    required this.status,
    required this.interactionEnabled,
    required this.currentAnswer,
    required this.onOptionSelected,
    required this.onTextChanged,
    this.submittedAnswer,
    this.textController,
    super.key,
  });

  final Question question;
  final int position;
  final int total;
  final Color primaryColor;
  final LessonActivityStatus status;
  final bool interactionEnabled;
  final String currentAnswer;
  final String? submittedAnswer;
  final TextEditingController? textController;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<String> onTextChanged;

  bool get isCurrent => status == LessonActivityStatus.active;
  bool get isCorrect => status == LessonActivityStatus.answeredCorrect;

  @override
  Widget build(BuildContext context) => Semantics(
    label: isCurrent ? AppStrings.currentActivity : AppStrings.answeredActivity,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.pageHorizontal,
        vertical: UiSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.activityPosition(position, total), style: UiText.p),
          const SizedBox(height: UiSpacing.xs),
          Text(question.prompt, style: UiText.h5.copyWith(color: primaryColor)),
          const SizedBox(height: UiSpacing.lg),
          if (question.type == QuestionType.multipleChoice)
            ...question.options.map(_option)
          else if (isCurrent)
            AppTextField(
              hint: AppStrings.correctAnswer,
              controller: textController,
              showSearchIcon: false,
              onChanged: onTextChanged,
            )
          else
            QuestionOption(
              label: submittedAnswer ?? '',
              selected: true,
              state: isCorrect
                  ? QuestionOptionState.correct
                  : QuestionOptionState.incorrect,
              onTap: null,
            ),
          if (!isCurrent) ...[
            const SizedBox(height: UiSpacing.xs),
            Text(
              isCorrect
                  ? AppStrings.correctFeedback
                  : AppStrings.incorrectFeedback,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isCorrect ? UiColor.success : UiColor.error,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _option(String option) {
    final selected = isCurrent
        ? currentAnswer == option
        : submittedAnswer == option;
    final state = isCurrent
        ? null
        : selected
        ? (isCorrect
              ? QuestionOptionState.correct
              : QuestionOptionState.incorrect)
        : QuestionOptionState.disabled;
    return QuestionOption(
      key: ValueKey('lesson-option-${question.id}-$option'),
      label: option,
      selected: selected,
      state: state,
      bottomSpacing: UiSpacing.xs,
      onTap: isCurrent && interactionEnabled
          ? () => onOptionSelected(option)
          : null,
    );
  }
}
