import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'exercise_chip.dart';
import 'exercise_question_prompt.dart';

/// Exercício de preencher lacuna: frase com um espaço vazio e banco de opções.
class ExerciseFillBlank extends StatelessWidget {
  const ExerciseFillBlank({
    this.question,
    required this.sentence,
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

  /// Frase com a lacuna marcada por [Question.blankToken].
  final String sentence;
  final List<String> options;
  final String currentAnswer;
  final String? submittedAnswer;
  final Color primaryColor;
  final bool isCurrent;
  final bool isCorrect;
  final bool interactionEnabled;
  final ValueChanged<String> onOptionSelected;

  /// Opção mais longa: define a largura da lacuna, evitando que ela salte de
  /// tamanho a cada escolha.
  String get _widestOption => options.reduce(
    (widest, option) => option.length > widest.length ? option : widest,
  );

  @override
  Widget build(BuildContext context) {
    final selected = isCurrent ? currentAnswer : (submittedAnswer ?? '');
    final accent = isCurrent
        ? primaryColor
        : isCorrect
        ? UiColor.success
        : UiColor.error;

    final parts = sentence.split(Question.blankToken);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question != null)
          ExerciseQuestionPrompt(
            question: question!,
            primaryColor: primaryColor,
          ),
        Text.rich(
          TextSpan(
            children: [
              for (var index = 0; index < parts.length; index++) ...[
                TextSpan(text: parts[index]),
                if (index < parts.length - 1)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _BlankSlot(
                      value: selected,
                      widestOption: _widestOption,
                      // O filete acompanha a cor do texto da frase e só muda
                      // depois da correção: escolher uma opção não altera
                      // borda nem fundo da lacuna.
                      borderColor: isCurrent ? UiColor.textPrimary : accent,
                      textColor: accent,
                    ),
                  ),
              ],
            ],
          ),
          style: UiText.h6,
        ),
        const SizedBox(height: UiSpacing.xl),
        Wrap(
          spacing: UiSpacing.xs,
          runSpacing: UiSpacing.xs,
          alignment: WrapAlignment.center,
          children: options.map((option) {
            final isPicked = selected == option;
            final state = !isPicked
                ? ExerciseChipState.normal
                : isCurrent
                ? ExerciseChipState.selected
                : isCorrect
                ? ExerciseChipState.correct
                : ExerciseChipState.incorrect;

            return ExerciseChip(
              key: ValueKey('fill-blank-$option'),
              label: option,
              accentColor: primaryColor,
              state: state,
              onTap: isCurrent && interactionEnabled
                  ? () => onOptionSelected(option)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Lacuna com filete reto embaixo, dimensionada pela opção mais longa.
class _BlankSlot extends StatelessWidget {
  const _BlankSlot({
    required this.value,
    required this.widestOption,
    required this.borderColor,
    required this.textColor,
  });

  final String value;
  final String widestOption;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final style = UiText.h6.copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UiSpacing.xxs),
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.xs,
        vertical: UiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Reserva a largura da maior opção, com a folga do padding.
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(widestOption, style: style),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
