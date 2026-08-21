import 'package:flutter/material.dart';

import '../../../models/model_question.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class ExerciseQuestionPrompt extends StatelessWidget {
  const ExerciseQuestionPrompt({
    required this.question,
    required this.primaryColor,
    super.key,
  });

  final Question question;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: UiSpacing.lg),
    child: Text(question.prompt, style: UiText.h6),
  );
}
