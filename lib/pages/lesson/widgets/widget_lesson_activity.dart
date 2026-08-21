import 'package:flutter/material.dart';

import '../../../enums/question_type.dart';
import '../../../l10n/app_strings.dart';
import '../../../models/model_question.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_spacing.dart';
import 'exercise_essay.dart';
import 'exercise_fill_blank.dart';
import 'exercise_image_choice.dart';
import 'exercise_matching.dart';
import 'exercise_memory.dart';
import 'exercise_multiple_choice.dart';
import 'exercise_ordering.dart';
import 'exercise_sequencing.dart';
import 'exercise_text_input.dart';
import 'exercise_true_false.dart';
import 'exercise_word_completion.dart';

enum LessonActivityStatus { active, answeredCorrect, answeredIncorrect }

const _kMemoryDone = '__memory_done__';
const _kMemoryIncorrect = '__memory_incorrect__';

class LessonActivity extends StatelessWidget {
  const LessonActivity({
    required this.question,
    required this.position,
    required this.total,
    required this.primaryColor,
    required this.status,
    required this.interactionEnabled,
    required this.currentAnswer,
    required this.onOptionSelected,
    required this.onTextChanged,
    this.submittedAnswer,
    this.textController,
    super.key,
  });

  final Question question;
  final int position;
  final int total;
  final Color primaryColor;
  final LessonActivityStatus status;
  final bool interactionEnabled;
  final String currentAnswer;
  final String? submittedAnswer;
  final TextEditingController? textController;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<String> onTextChanged;

  bool get isCurrent => status == LessonActivityStatus.active;
  bool get isCorrect => status == LessonActivityStatus.answeredCorrect;

  @override
  Widget build(BuildContext context) => Semantics(
    label: isCurrent ? AppStrings.currentActivity : AppStrings.answeredActivity,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.pageHorizontal,
        vertical: UiSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _exercise(),
      ),
    ),
  );

  List<Widget> _exercise() => switch (question.type) {
    QuestionType.matching => [
      ExerciseMatching(
        key: ValueKey('matching-${question.id}'),
        question: question,
        pairs: question.pairs!,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        initialAnswer: currentAnswer,
        answeredCorrect: isCurrent ? null : isCorrect,
        onChanged: onOptionSelected,
      ),
    ],

    QuestionType.memory => [
      ExerciseMemory(
        key: ValueKey('memory-${question.id}'),
        question: question,
        pairs: question.pairs!,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        revealAll: !isCurrent,
        onCompleted: (allCorrect) =>
            onOptionSelected(allCorrect ? _kMemoryDone : _kMemoryIncorrect),
      ),
    ],

    QuestionType.ordering => [
      ExerciseOrdering(
        key: ValueKey('ordering-${question.id}'),
        question: question,
        words: question.options,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        initialAnswer: submittedAnswer,
        onChanged: onOptionSelected,
      ),
    ],

    QuestionType.sequencing => [
      ExerciseSequencing(
        key: ValueKey('sequencing-${question.id}'),
        question: question,
        items: question.options,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        initialAnswer: submittedAnswer,
        answeredCorrect: isCurrent ? null : isCorrect,
        onChanged: onOptionSelected,
      ),
    ],

    QuestionType.multipleChoice => [
      ExerciseMultipleChoice(
        question: question,
        questionId: question.id,
        options: question.options,
        currentAnswer: currentAnswer,
        submittedAnswer: submittedAnswer,
        primaryColor: primaryColor,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        interactionEnabled: interactionEnabled,
        onOptionSelected: onOptionSelected,
      ),
    ],

    QuestionType.trueFalse => [
      ExerciseTrueFalse(
        question: question,
        options: question.options,
        currentAnswer: currentAnswer,
        submittedAnswer: submittedAnswer,
        primaryColor: primaryColor,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        interactionEnabled: interactionEnabled,
        onOptionSelected: onOptionSelected,
      ),
    ],

    QuestionType.imageChoice => [
      ExerciseImageChoice(
        question: question,
        options: question.options,
        currentAnswer: currentAnswer,
        submittedAnswer: submittedAnswer,
        primaryColor: primaryColor,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        interactionEnabled: interactionEnabled,
        onOptionSelected: onOptionSelected,
      ),
    ],

    QuestionType.fillBlank => [
      ExerciseFillBlank(
        question: question,
        sentence: question.template!,
        options: question.options,
        currentAnswer: currentAnswer,
        submittedAnswer: submittedAnswer,
        primaryColor: primaryColor,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        interactionEnabled: interactionEnabled,
        onOptionSelected: onOptionSelected,
      ),
    ],

    QuestionType.wordCompletion => [
      if (isCurrent)
        ExerciseWordCompletion(
          key: ValueKey('word-completion-${question.id}'),
          question: question,
          template: question.template!,
          letters: question.options,
          primaryColor: primaryColor,
          enabled: interactionEnabled,
          onChanged: onOptionSelected,
        )
      else
        ExerciseOption(
          label: submittedAnswer ?? '',
          selected: true,
          state: isCorrect
              ? ExerciseOptionState.correct
              : ExerciseOptionState.incorrect,
          accentColor: isCorrect ? UiColor.success : UiColor.error,
          onTap: null,
        ),
    ],

    QuestionType.essay => [
      ExerciseEssay(
        question: question,
        primaryColor: primaryColor,
        textController: textController,
        submittedAnswer: submittedAnswer,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        enabled: interactionEnabled,
        onTextChanged: onTextChanged,
      ),
    ],

    QuestionType.textInput => [
      ExerciseTextInput(
        question: question,
        primaryColor: primaryColor,
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        textController: textController,
        submittedAnswer: submittedAnswer,
        onTextChanged: onTextChanged,
      ),
    ],
  };
}
