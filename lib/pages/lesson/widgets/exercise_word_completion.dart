import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_chip.dart';
import 'exercise_question_prompt.dart';

/// Exercício de completar palavra.
///
/// Exibe a palavra com lacunas ([Question.blankToken]) e um banco de letras.
/// Tocar uma letra preenche a próxima lacuna vazia; tocar uma lacuna a esvazia.
/// Enquanto houver lacuna aberta, a resposta enviada é vazia.
class ExerciseWordCompletion extends StatefulWidget {
  const ExerciseWordCompletion({
    this.question,
    required this.template,
    required this.letters,
    required this.primaryColor,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final Question? question;

  /// Palavra com lacunas, ex.: `N_MERAD_R`.
  final String template;

  /// Banco de letras disponíveis.
  final List<String> letters;

  final Color primaryColor;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<ExerciseWordCompletion> createState() => _ExerciseWordCompletionState();
}

class _ExerciseWordCompletionState extends State<ExerciseWordCompletion> {
  /// Posições da palavra que precisam ser preenchidas.
  late final List<int> _blanks;

  /// Lacuna preenchida -> índice da letra usada no banco.
  final Map<int, int> _filled = {};

  @override
  void initState() {
    super.initState();
    _blanks = [
      for (final entry in widget.template.split('').indexed)
        if (entry.$2 == Question.blankToken) entry.$1,
    ];
  }

  void _useLetter(int letterIndex) {
    if (!widget.enabled || _filled.containsValue(letterIndex)) return;
    final nextBlank = _blanks.firstWhere(
      (blank) => !_filled.containsKey(blank),
      orElse: () => -1,
    );
    if (nextBlank == -1) return;
    setState(() => _filled[nextBlank] = letterIndex);
    _notifyChange();
  }

  void _clearBlank(int blank) {
    if (!widget.enabled || !_filled.containsKey(blank)) return;
    setState(() => _filled.remove(blank));
    _notifyChange();
  }

  void _notifyChange() {
    if (_filled.length < _blanks.length) {
      widget.onChanged('');
      return;
    }
    final assembled = widget.template.split('').indexed.map((entry) {
      final index = entry.$1;
      return _filled.containsKey(index)
          ? widget.letters[_filled[index]!]
          : entry.$2;
    }).join();
    widget.onChanged(assembled);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question != null)
          ExerciseQuestionPrompt(
            question: widget.question!,
            primaryColor: widget.primaryColor,
          ),
        Wrap(
          spacing: UiSpacing.xxs,
          runSpacing: UiSpacing.xs,
          alignment: WrapAlignment.center,
          children: widget.template.split('').indexed.map((entry) {
            final position = entry.$1;
            final character = entry.$2;
            final isBlank = character == Question.blankToken;
            final letterIndex = _filled[position];

            return _LetterBox(
              letter: letterIndex != null
                  ? widget.letters[letterIndex]
                  : isBlank
                  ? ''
                  : character,
              isBlank: isBlank,
              accentColor: widget.primaryColor,
              onTap: isBlank && letterIndex != null && widget.enabled
                  ? () => _clearBlank(position)
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: UiSpacing.xl),
        Wrap(
          spacing: UiSpacing.xs,
          runSpacing: UiSpacing.xs,
          alignment: WrapAlignment.center,
          children: widget.letters.indexed.map((entry) {
            final index = entry.$1;
            final letter = entry.$2;
            final used = _filled.containsValue(index);

            return Opacity(
              opacity: used ? .3 : 1,
              child: ExerciseChip(
                key: ValueKey('word-letter-$index'),
                label: letter,
                accentColor: widget.primaryColor,
                state: used
                    ? ExerciseChipState.selected
                    : ExerciseChipState.normal,
                fontSize: 18,
                onTap: widget.enabled && !used ? () => _useLetter(index) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LetterBox extends StatelessWidget {
  const _LetterBox({
    required this.letter,
    required this.isBlank,
    required this.accentColor,
    required this.onTap,
  });

  final String letter;
  final bool isBlank;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final filled = letter.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 48,
        decoration: BoxDecoration(
          // Filete reto na cor do texto: preencher a lacuna não muda borda
          // nem fundo, só revela a letra escolhida.
          border: isBlank
              ? const Border(
                  bottom: BorderSide(color: UiColor.textPrimary, width: 2.5),
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          filled ? letter : '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isBlank ? accentColor : UiColor.textPrimary,
          ),
        ),
      ),
    );
  }
}
