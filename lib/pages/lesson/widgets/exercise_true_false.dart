import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_option.dart';
import 'package:eureka/ui/ui_size.dart';
import 'package:eureka/ui/ui_spacing.dart';
import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import 'exercise_question_prompt.dart';

class ExerciseTrueFalse extends StatelessWidget {
  const ExerciseTrueFalse({
    this.question,
    required this.options,
    required this.currentAnswer,
    required this.primaryColor,
    required this.onOptionSelected,
    this.submittedAnswer,
    this.isCurrent = true,
    this.isCorrect = false,
    this.interactionEnabled = true,
    super.key,
  });

  final Question? question;
  final List<String> options;
  final String currentAnswer;
  final String? submittedAnswer;
  final Color primaryColor;
  final bool isCurrent;
  final bool isCorrect;
  final bool interactionEnabled;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (question != null)
        ExerciseQuestionPrompt(question: question!, primaryColor: primaryColor),
      ...options.map((option) {
        final selected = isCurrent
            ? currentAnswer == option
            : submittedAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: UiSpacing.sm),
          child: _StatementButton(
            label: option,
            selected: selected,
            answered: !isCurrent,
            correct: isCorrect,
            accentColor: primaryColor,
            onTap: isCurrent && interactionEnabled
                ? () => onOptionSelected(option)
                : null,
          ),
        );
      }),
    ],
  );
}

class _StatementButton extends StatelessWidget {
  const _StatementButton({
    required this.label,
    required this.selected,
    required this.answered,
    required this.correct,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool answered;
  final bool correct;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = !selected
        ? UiColor.outline
        : answered
        ? (correct ? UiColor.success : UiColor.error)
        : accentColor;

    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      child: Opacity(
        opacity: answered && !selected ? .55 : 1,
        child: Material(
          color: selected ? accent.withValues(alpha: .16) : UiColor.surface,
          borderRadius: BorderRadius.circular(UiOption.radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: Container(
              height: UiSize.buttonHeightLg,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UiOption.radius),
                border: Border.all(color: accent, width: UiOption.borderWidth),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: selected ? accent : UiColor.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
