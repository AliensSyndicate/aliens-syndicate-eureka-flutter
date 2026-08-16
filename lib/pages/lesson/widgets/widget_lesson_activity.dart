import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';

import '../../../enums/question_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_matching.dart';
import 'exercise_multiple_choice.dart';
import 'exercise_text_input.dart';

enum LessonActivityStatus { active, answeredCorrect, answeredIncorrect }

/// Token sentinela usado para sinalizar que o exercício de ligação foi concluído.
const _kMatchingDone = '__matching_done__';

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
    child: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
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
          if (question.type == QuestionType.matching) ...[
            Text(
              AppStrings.matchingPrompt,
              style: UiText.p.copyWith(color: UiColor.textSecondary),
            ),
            const SizedBox(height: UiSpacing.sm),
            if (isCurrent)
              ExerciseMatching(
                key: ValueKey('matching-${question.id}'),
                pairs: question.pairs!,
                primaryColor: primaryColor,
                enabled: interactionEnabled,
                onCompleted: (allCorrect) => onOptionSelected(
                  allCorrect ? _kMatchingDone : '__matching_incorrect__',
                ),
              )
            else
              _MatchingDoneIndicator(correct: isCorrect),
          ] else if (question.type == QuestionType.multipleChoice)
            ExerciseMultipleChoice(
              questionId: question.id,
              options: question.options,
              currentAnswer: currentAnswer,
              submittedAnswer: submittedAnswer,
              primaryColor: primaryColor,
              isCurrent: isCurrent,
              isCorrect: isCorrect,
              interactionEnabled: interactionEnabled,
              onOptionSelected: onOptionSelected,
            )
          else
            ExerciseTextInput(
              isCurrent: isCurrent,
              isCorrect: isCorrect,
              textController: textController,
              submittedAnswer: submittedAnswer,
              onTextChanged: onTextChanged,
            ),
          if (!isCurrent && question.type != QuestionType.matching) ...[
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
}

class _MatchingDoneIndicator extends StatelessWidget {
  const _MatchingDoneIndicator({required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? UiColor.success : UiColor.error;
    final icon = correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = correct
        ? AppStrings.matchingComplete
        : AppStrings.incorrectFeedback;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: UiSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}
