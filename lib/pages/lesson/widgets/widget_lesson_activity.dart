import 'package:eureka/ui/ui_text.dart';
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

const _kMatchingDone = '__matching_done__';
const _kMatchingIncorrect = '__matching_incorrect__';
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
      _questionPrompt(),
      _hint(AppStrings.matchingPrompt),
      if (isCurrent)
        ExerciseMatching(
          key: ValueKey('matching-${question.id}'),
          pairs: question.pairs!,
          primaryColor: primaryColor,
          enabled: interactionEnabled,
          onCompleted: (allCorrect) => onOptionSelected(
            allCorrect ? _kMatchingDone : _kMatchingIncorrect,
          ),
        )
      else
        _DoneIndicator(correct: isCorrect, label: AppStrings.matchingComplete),
    ],

    QuestionType.memory => [
      _questionPrompt(),
      _hint(AppStrings.memoryPrompt),
      if (isCurrent)
        ExerciseMemory(
          key: ValueKey('memory-${question.id}'),
          pairs: question.pairs!,
          primaryColor: primaryColor,
          enabled: interactionEnabled,
          onCompleted: (allCorrect) =>
              onOptionSelected(allCorrect ? _kMemoryDone : _kMemoryIncorrect),
        )
      else
        _DoneIndicator(correct: isCorrect, label: AppStrings.memoryComplete),
    ],

    QuestionType.ordering => [
      _questionPrompt(),
      _hint(AppStrings.orderingPrompt),
      ExerciseOrdering(
        key: ValueKey('ordering-${question.id}'),
        words: question.options,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        initialAnswer: submittedAnswer,
        onChanged: onOptionSelected,
      ),
    ],

    QuestionType.sequencing => [
      _questionPrompt(),
      _hint(AppStrings.sequencingPrompt),
      ExerciseSequencing(
        key: ValueKey('sequencing-${question.id}'),
        items: question.options,
        primaryColor: primaryColor,
        enabled: interactionEnabled,
        initialAnswer: submittedAnswer,
        answeredCorrect: isCurrent ? null : isCorrect,
        onChanged: onOptionSelected,
      ),
    ],

    QuestionType.multipleChoice => [
      _questionPrompt(),
      ExerciseMultipleChoice(
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
      _questionPrompt(),
      ExerciseTrueFalse(
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
      _questionPrompt(),
      ExerciseImageChoice(
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
      _questionPrompt(),
      ExerciseFillBlank(
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
      _questionPrompt(),
      if (isCurrent)
        ExerciseWordCompletion(
          key: ValueKey('word-completion-${question.id}'),
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
      _questionPrompt(),
      ExerciseEssay(
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
      _questionPrompt(),
      ExerciseTextInput(
        isCurrent: isCurrent,
        isCorrect: isCorrect,
        textController: textController,
        submittedAnswer: submittedAnswer,
        onTextChanged: onTextChanged,
      ),
    ],
  };

  Widget _questionPrompt() => Padding(
    padding: const EdgeInsets.only(bottom: UiSpacing.lg),
    child: Text(
      question.prompt,
      style: UiText.h6.copyWith(color: primaryColor),
    ),
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.only(bottom: UiSpacing.sm),
    child: Text(text, style: UiText.p.copyWith(color: UiColor.textSecondary)),
  );
}

class _DoneIndicator extends StatelessWidget {
  const _DoneIndicator({required this.correct, required this.label});

  final bool correct;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = correct ? UiColor.success : UiColor.error;
    return Text(
      correct ? label : AppStrings.answeredActivity,
      style: UiText.label.copyWith(color: color),
    );
  }
}
