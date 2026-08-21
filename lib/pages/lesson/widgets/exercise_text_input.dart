import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/components/app_text_field.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import 'exercise_multiple_choice.dart';
import 'exercise_question_prompt.dart';

class ExerciseTextInput extends StatelessWidget {
  const ExerciseTextInput({
    this.question,
    required this.primaryColor,
    required this.onTextChanged,
    this.textController,
    this.submittedAnswer,
    this.isCurrent = true,
    this.isCorrect = false,
    super.key,
  });

  final Question? question;
  final Color primaryColor;
  final TextEditingController? textController;
  final String? submittedAnswer;
  final bool isCurrent;
  final bool isCorrect;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    final Widget answer;
    if (isCurrent) {
      answer = AppTextField(
        hint: AppStrings.correctAnswer,
        controller: textController,
        showSearchIcon: false,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        onChanged: onTextChanged,
      );
    } else {
      answer = ExerciseOption(
        label: submittedAnswer ?? '',
        selected: true,
        state: isCorrect
            ? ExerciseOptionState.correct
            : ExerciseOptionState.incorrect,
        accentColor: isCorrect ? UiColor.success : UiColor.error,
        onTap: null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question != null)
          ExerciseQuestionPrompt(
            question: question!,
            primaryColor: primaryColor,
          ),
        answer,
      ],
    );
  }
}
