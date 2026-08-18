import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

/// Exercício de escolha por imagem: grade 2x2 de figuras.
class ExerciseImageChoice extends StatelessWidget {
  const ExerciseImageChoice({
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

  /// Cada opção é a própria figura (sequência de glifos) exibida no cartão.
  final List<String> options;
  final String currentAnswer;
  final String? submittedAnswer;
  final Color primaryColor;
  final bool isCurrent;
  final bool isCorrect;
  final bool interactionEnabled;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: UiSpacing.sm,
    crossAxisSpacing: UiSpacing.sm,
    childAspectRatio: 1,
    children: options.map((option) {
      final selected = isCurrent
          ? currentAnswer == option
          : submittedAnswer == option;

      final accent = !selected
          ? UiColor.outline
          : isCurrent
          ? primaryColor
          : isCorrect
          ? UiColor.success
          : UiColor.error;

      final enabled = isCurrent && interactionEnabled;

      return Semantics(
        selected: selected,
        button: true,
        enabled: enabled,
        child: Opacity(
          opacity: !isCurrent && !selected ? .55 : 1,
          child: Material(
            color: selected ? accent.withValues(alpha: .16) : UiColor.surface,
            borderRadius: BorderRadius.circular(UiOption.radius),
            child: InkWell(
              onTap: enabled ? () => onOptionSelected(option) : null,
              borderRadius: BorderRadius.circular(UiOption.radius),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UiOption.radius),
                  border: Border.all(
                    color: accent,
                    width: selected ? 3 : UiOption.borderWidth,
                  ),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(UiSpacing.sm),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 30, height: 1.1),
                        ),
                      ),
                    ),
                    if (!isCurrent && selected)
                      Positioned(
                        top: UiSpacing.xs,
                        right: UiSpacing.xs,
                        child: Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: accent,
                          size: UiSize.iconSm,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}
