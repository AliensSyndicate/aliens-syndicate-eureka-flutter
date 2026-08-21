import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';

enum ExerciseChipState { normal, selected, correct, incorrect }

/// Chip compartilhado pelos exercícios de escolha rápida (lacuna, letras).
class ExerciseChip extends StatelessWidget {
  const ExerciseChip({
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.state = ExerciseChipState.normal,
    this.fontSize = 15,
    super.key,
  });

  final String label;
  final Color accentColor;
  final VoidCallback? onTap;
  final ExerciseChipState state;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final border = switch (state) {
      ExerciseChipState.selected => accentColor,
      ExerciseChipState.correct => UiColor.success,
      ExerciseChipState.incorrect => UiColor.error,
      ExerciseChipState.normal => UiColor.outline,
    };

    return Material(
      color: UiColor.surfaceElevated,
      borderRadius: BorderRadius.circular(UiOption.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiOption.radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiOption.radius),
            border: Border.all(color: border, width: UiOption.borderWidth),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              color: state == ExerciseChipState.normal
                  ? UiColor.textPrimary
                  : border,
            ),
          ),
        ),
      ),
    );
  }
}
