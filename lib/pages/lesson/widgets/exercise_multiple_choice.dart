import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_question_prompt.dart';

enum ExerciseOptionState { normal, selected, correct, incorrect, disabled }

typedef QuestionOptionState = ExerciseOptionState;
typedef QuestionOption = ExerciseOption;

/// Exercício de múltipla escolha.
class ExerciseMultipleChoice extends StatelessWidget {
  const ExerciseMultipleChoice({
    this.question,
    required this.options,
    required this.currentAnswer,
    required this.primaryColor,
    required this.onOptionSelected,
    this.submittedAnswer,
    this.isCurrent = true,
    this.isCorrect = false,
    this.interactionEnabled = true,
    this.questionId = '',
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
  final String questionId;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question != null)
          ExerciseQuestionPrompt(
            question: question!,
            primaryColor: primaryColor,
          ),
        ...options.indexed.map((e) {
          final index = e.$1;
          final option = e.$2;
          final selected = isCurrent
              ? currentAnswer == option
              : submittedAnswer == option;
          final state = isCurrent
              ? null
              : selected
              ? (isCorrect
                    ? ExerciseOptionState.correct
                    : ExerciseOptionState.incorrect)
              : ExerciseOptionState.disabled;

          return ExerciseOption(
            key: ValueKey('lesson-option-$questionId-$option'),
            label: option,
            selected: selected,
            index: index,
            accentColor: primaryColor,
            state: state,
            bottomSpacing: UiSpacing.xs,
            onTap: isCurrent && interactionEnabled
                ? () => onOptionSelected(option)
                : null,
          );
        }),
      ],
    );
  }
}

/// Componente de opção individual com indicador A/B/C/D.
class ExerciseOption extends StatelessWidget {
  const ExerciseOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.index,
    this.state,
    this.accentColor,
    this.bottomSpacing = UiSpacing.sm,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? index;
  final ExerciseOptionState? state;
  final Color? accentColor;
  final double bottomSpacing;

  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final current =
        state ??
        (selected ? ExerciseOptionState.selected : ExerciseOptionState.normal);

    final selectedAccent = accentColor ?? UiColor.primary;

    final accent = switch (current) {
      ExerciseOptionState.selected => selectedAccent,
      ExerciseOptionState.correct => UiColor.success,
      ExerciseOptionState.incorrect => UiColor.error,
      _ => UiColor.outline,
    };

    final disabled = current == ExerciseOptionState.disabled;
    final interactive = !disabled && onTap != null;

    final indexLabel = (index != null && index! < _labels.length)
        ? _labels[index!]
        : '';

    final isNormalOrDisabled =
        current == ExerciseOptionState.normal || disabled;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Semantics(
        selected: selected,
        button: true,
        enabled: interactive,
        child: Opacity(
          opacity: disabled ? .55 : 1,
          child: Material(
            color: isNormalOrDisabled
                ? UiColor.surface
                : accent.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: InkWell(
              onTap: interactive ? onTap : null,
              borderRadius: BorderRadius.circular(UiOption.radius),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: UiOption.minHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: UiOption.paddingHorizontal,
                  vertical: UiOption.paddingVertical,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UiOption.radius),
                  border: Border.all(
                    color: accent,
                    width: UiOption.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    _IndexBadge(
                      label: indexLabel,
                      accent: accent,
                      filled: !isNormalOrDisabled,
                    ),
                    const SizedBox(width: UiSpacing.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({
    required this.label,
    required this.accent,
    required this.filled,
  });

  final String label;
  final Color accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? accent : Colors.transparent,
        border: Border.all(color: accent, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: filled ? Colors.white : accent,
        ),
      ),
    );
  }
}
