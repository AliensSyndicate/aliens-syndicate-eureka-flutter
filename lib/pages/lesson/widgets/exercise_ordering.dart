import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_question_prompt.dart';

/// Exercício de ordenação de frase (Sentence Ordering) estilo Duolingo.
///
/// - Área superior: 2 linhas de pauta horizontais. As palavras montadas repousam
///   diretamente sobre a Linha 1; ao quebrar para a 2ª linha, repousam sobre a Linha 2.
/// - Área inferior: banco de palavras disponíveis (sem linhas de pauta).
/// - Suporta toque simples e arrastar para reordenar (drag & drop).
class ExerciseOrdering extends StatefulWidget {
  const ExerciseOrdering({
    this.question,
    required this.words,
    required this.primaryColor,
    required this.onChanged,
    this.initialAnswer,
    this.enabled = true,
    super.key,
  });

  final Question? question;

  /// Lista de palavras disponíveis no banco.
  final List<String> words;

  /// Cor temática da matéria atual.
  final Color primaryColor;

  /// Callback com a frase montada em tempo real (separada por espaço).
  final ValueChanged<String> onChanged;

  /// Resposta submetida anteriormente (para histórico).
  final String? initialAnswer;

  /// Se a interação está habilitada.
  final bool enabled;

  @override
  State<ExerciseOrdering> createState() => _ExerciseOrderingState();
}

class _ExerciseOrderingState extends State<ExerciseOrdering> {
  late final List<String> _bankWords;
  final List<int> _selectedIndices = [];

  static const double _rowHeight = 58.0;
  static const int _lineCount = 2;

  @override
  void initState() {
    super.initState();
    _bankWords = [...widget.words]..shuffle(math.Random());

    if (widget.initialAnswer != null && widget.initialAnswer!.isNotEmpty) {
      final parts = widget.initialAnswer!.split(' ');
      final used = <int>{};
      for (final part in parts) {
        final idx = _bankWords.indexed
            .firstWhere(
              (e) => e.$2 == part && !used.contains(e.$1),
              orElse: () => (-1, ''),
            )
            .$1;
        if (idx != -1) {
          used.add(idx);
          _selectedIndices.add(idx);
        }
      }
    }
  }

  void _selectWord(int bankIndex) {
    if (!widget.enabled || _selectedIndices.contains(bankIndex)) return;
    setState(() {
      _selectedIndices.add(bankIndex);
    });
    _notifyChange();
  }

  void _unselectWord(int selectedPosition) {
    if (!widget.enabled || selectedPosition >= _selectedIndices.length) return;
    setState(() {
      _selectedIndices.removeAt(selectedPosition);
    });
    _notifyChange();
  }

  void _reorderWord(int fromIndex, int toIndex) {
    if (!widget.enabled || fromIndex == toIndex) return;
    setState(() {
      final item = _selectedIndices.removeAt(fromIndex);
      final adjustedTo = toIndex > fromIndex ? toIndex - 1 : toIndex;
      _selectedIndices.insert(
        adjustedTo.clamp(0, _selectedIndices.length),
        item,
      );
    });
    _notifyChange();
  }

  void _notifyChange() {
    final assembled = _selectedIndices.map((i) => _bankWords[i]).join(' ');
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
        // -------------------------------------------------------------------
        // Área superior: Pauta de linhas de montagem estilo Duolingo
        // -------------------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: _rowHeight * _lineCount,
          child: Stack(
            children: [
              // Fundo: 2 linhas de base horizontais de pauta com margin-top
              Column(
                children: List.generate(_lineCount, (index) {
                  return SizedBox(
                    height: _rowHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 1.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: UiColor.outline.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Frente: Palavras montadas que assentam sobre cada linha
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Wrap(
                  spacing: UiSpacing.xs,
                  runSpacing: 16.0,
                  children: _selectedIndices.indexed.map((e) {
                    final position = e.$1;
                    final bankIdx = e.$2;
                    final word = _bankWords[bankIdx];

                    return DragTarget<int>(
                      onWillAcceptWithDetails: (details) =>
                          widget.enabled && details.data != position,
                      onAcceptWithDetails: (details) {
                        _reorderWord(details.data, position);
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovered = candidateData.isNotEmpty;

                        return LongPressDraggable<int>(
                          data: position,
                          delay: const Duration(milliseconds: 120),
                          feedback: Material(
                            color: Colors.transparent,
                            child: _WordChip(
                              label: word,
                              accentColor: widget.primaryColor,
                              isSelected: true,
                              isDragging: true,
                              onTap: null,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.25,
                            child: _WordChip(
                              label: word,
                              accentColor: widget.primaryColor,
                              isSelected: true,
                              onTap: null,
                            ),
                          ),
                          child: AnimatedScale(
                            scale: isHovered ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: _WordChip(
                              label: word,
                              accentColor: widget.primaryColor,
                              isSelected: true,
                              isDropTarget: isHovered,
                              onTap: widget.enabled
                                  ? () => _unselectWord(position)
                                  : null,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: UiSpacing.xl),

        // -------------------------------------------------------------------
        // Área inferior: Banco de palavras disponíveis (sem linhas de pauta)
        // -------------------------------------------------------------------
        Wrap(
          spacing: UiSpacing.xs,
          runSpacing: UiSpacing.sm,
          alignment: WrapAlignment.center,
          children: _bankWords.indexed.map((e) {
            final index = e.$1;
            final word = e.$2;
            final isUsed = _selectedIndices.contains(index);

            return isUsed
                ? _PlaceholderChip(label: word)
                : _WordChip(
                    label: word,
                    accentColor: widget.primaryColor,
                    isSelected: false,
                    onTap: widget.enabled ? () => _selectWord(index) : null,
                  );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de palavra interativo
// ---------------------------------------------------------------------------

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.label,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    this.isDragging = false,
    this.isDropTarget = false,
  });

  final String label;
  final Color accentColor;
  final bool isSelected;
  final bool isDragging;
  final bool isDropTarget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border = isDropTarget
        ? UiColor.info
        : isSelected
        ? accentColor
        : UiColor.outline;

    final bg = isDragging
        ? accentColor.withValues(alpha: .35)
        : isSelected
        ? accentColor.withValues(alpha: .18)
        : UiColor.surfaceElevated;

    return Material(
      color: bg,
      elevation: isDragging ? 6 : 0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(UiOption.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiOption.radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiOption.radius),
            border: Border.all(color: border, width: UiOption.borderWidth),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: UiColor.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip placeholder (slot vazio no banco de palavras)
// ---------------------------------------------------------------------------

class _PlaceholderChip extends StatelessWidget {
  const _PlaceholderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: UiColor.surface.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(UiOption.radius),
        border: Border.all(
          color: UiColor.outline.withValues(alpha: .25),
          width: UiOption.borderWidth,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Colors.transparent,
        ),
      ),
    );
  }
}
