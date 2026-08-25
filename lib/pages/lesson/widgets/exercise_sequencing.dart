import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_question_prompt.dart';

/// Exercício de ordenação de itens (linha do tempo / passos de um processo).
///
/// A lista começa embaralhada e a ordem atual é reportada continuamente, então
/// o aluno pode confirmar sem precisar mover nada.
class ExerciseSequencing extends StatefulWidget {
  const ExerciseSequencing({
    this.question,
    required this.items,
    required this.primaryColor,
    required this.onChanged,
    this.initialAnswer,
    this.enabled = true,
    this.answeredCorrect,
    super.key,
  });

  /// Separador usado para montar a resposta enviada ao gabarito.
  static const separator = ' | ';

  final Question? question;
  final List<String> items;
  final Color primaryColor;
  final ValueChanged<String> onChanged;

  /// Resposta submetida anteriormente (histórico).
  final String? initialAnswer;

  final bool enabled;

  /// Resultado da correção; `null` enquanto a atividade não foi respondida.
  final bool? answeredCorrect;

  @override
  State<ExerciseSequencing> createState() => _ExerciseSequencingState();
}

class _ExerciseSequencingState extends State<ExerciseSequencing> {
  late final List<String> _order;

  @override
  void initState() {
    super.initState();
    final previous = widget.initialAnswer;
    _order = previous != null && previous.isNotEmpty
        ? previous.split(ExerciseSequencing.separator)
        : ([...widget.items]..shuffle(math.Random()));

    // Sem resposta anterior: publica a ordem inicial para habilitar o envio.
    if (previous == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(_assembled);
      });
    }
  }

  String get _assembled => _order.join(ExerciseSequencing.separator);

  void _reorder(int oldIndex, int newIndex) {
    if (!widget.enabled) return;
    setState(() => _order.insert(newIndex, _order.removeAt(oldIndex)));
    widget.onChanged(_assembled);
  }

  @override
  Widget build(BuildContext context) {
    final accent = switch (widget.answeredCorrect) {
      true => UiColor.success,
      false => UiColor.error,
      null => UiColor.outline,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question != null)
          ExerciseQuestionPrompt(
            question: widget.question!,
            primaryColor: widget.primaryColor,
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _order.length,
          onReorderItem: _reorder,
          proxyDecorator: (child, index, animation) =>
              Material(color: Colors.transparent, child: child),
          itemBuilder: (context, index) {
            final tile = _SequenceTile(
              position: index + 1,
              label: _order[index],
              accent: accent,
              answered: widget.answeredCorrect != null,
            );
            return Padding(
              key: ValueKey('sequence-${_order[index]}'),
              padding: const EdgeInsets.only(bottom: UiSpacing.xs),
              child: widget.enabled
                  ? ReorderableDragStartListener(index: index, child: tile)
                  : tile,
            );
          },
        ),
      ],
    );
  }
}

class _SequenceTile extends StatelessWidget {
  const _SequenceTile({
    required this.position,
    required this.label,
    required this.accent,
    required this.answered,
  });

  final int position;
  final String label;
  final Color accent;
  final bool answered;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: UiOption.minHeight),
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.sm,
      vertical: UiSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: UiColor.surface,
      borderRadius: BorderRadius.circular(UiOption.radius),
      border: Border.all(color: accent, width: UiOption.borderWidth),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: accent, width: UiOption.borderWidth),
          ),
          alignment: Alignment.center,
          child: Text(
            '$position',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: UiSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: answered ? accent : UiColor.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
