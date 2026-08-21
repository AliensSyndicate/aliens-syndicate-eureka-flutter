import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_option.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';
import 'exercise_question_prompt.dart';

/// Exercício dissertativo: resposta livre em várias linhas com contador.
class ExerciseEssay extends StatelessWidget {
  const ExerciseEssay({
    this.question,
    required this.primaryColor,
    required this.onTextChanged,
    this.textController,
    this.submittedAnswer,
    this.isCurrent = true,
    this.isCorrect = false,
    this.enabled = true,
    super.key,
  });

  static const maxLength = 300;
  static const _minLines = 5;

  final Question? question;
  final Color primaryColor;
  final TextEditingController? textController;
  final String? submittedAnswer;
  final bool isCurrent;
  final bool isCorrect;
  final bool enabled;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    final Widget answer;
    if (!isCurrent) {
      final accent = isCorrect ? UiColor.success : UiColor.error;
      answer = _Frame(
        borderColor: accent,
        background: accent.withValues(alpha: .14),
        child: Text(submittedAnswer ?? '', style: UiText.p),
      );
    } else {
      final controller = textController;
      answer = _Frame(
        borderColor: UiColor.outline,
        background: UiColor.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: controller,
              enabled: enabled,
              onChanged: onTextChanged,
              maxLength: maxLength,
              maxLines: null,
              minLines: _minLines,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: primaryColor,
              style: UiText.p,
              decoration: const InputDecoration(
                hintText: AppStrings.essayHint,
                border: InputBorder.none,
                isCollapsed: true,
                counterText: '',
              ),
            ),
            const SizedBox(height: UiSpacing.xs),
            if (controller == null)
              Text(AppStrings.essayCounter(0, maxLength), style: UiText.label)
            else
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) => Text(
                  AppStrings.essayCounter(value.text.length, maxLength),
                  style: UiText.label,
                ),
              ),
          ],
        ),
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

class _Frame extends StatelessWidget {
  const _Frame({
    required this.borderColor,
    required this.background,
    required this.child,
  });

  final Color borderColor;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: UiSpacing.md,
      vertical: UiSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(UiOption.radius),
      border: Border.all(color: borderColor, width: UiOption.borderWidth),
    ),
    child: child,
  );
}
