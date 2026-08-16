import 'package:flutter/material.dart';

import '../../../app/components/app_text_field.dart';
import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import 'exercise_multiple_choice.dart';

/// Exercício de entrada de texto livre.
class ExerciseTextInput extends StatelessWidget {
  const ExerciseTextInput({
    required this.onTextChanged,
    this.textController,
    this.submittedAnswer,
    this.isCurrent = true,
    this.isCorrect = false,
    super.key,
  });

  final TextEditingController? textController;
  final String? submittedAnswer;
  final bool isCurrent;
  final bool isCorrect;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return AppTextField(
        hint: AppStrings.correctAnswer,
        controller: textController,
        showSearchIcon: false,
        onChanged: onTextChanged,
      );
    }

    return ExerciseOption(
      label: submittedAnswer ?? '',
      selected: true,
      state: isCorrect
          ? ExerciseOptionState.correct
          : ExerciseOptionState.incorrect,
      accentColor: isCorrect ? UiColor.success : UiColor.error,
      onTap: null,
    );
  }
}
