import 'package:flutter/material.dart';

import '../../controllers/controller_simulation.dart';
import '../../l10n/app_strings.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class PageSimulationReview extends StatefulWidget {
  const PageSimulationReview({required this.controller, super.key});
  final SimulationController controller;
  @override
  State<PageSimulationReview> createState() => _PageSimulationReviewState();
}

class _PageSimulationReviewState extends State<PageSimulationReview> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;
    final item = session.questions[index];
    final answer = session.answers[item.question.id];
    final correct =
        answer != null &&
        ServiceRegistry.answer.isCorrect(item.question, answer);
    final color = answer == null
        ? UiColor.warning
        : correct
        ? UiColor.success
        : UiColor.error;
    return Scaffold(
      appBar: AppBar(
        title: Text('${index + 1} de ${session.questions.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
                children: [
                  Text(
                    '${item.subjectTitle} · ${item.contentTitle}',
                    style: UiText.label,
                  ),
                  const SizedBox(height: UiSpacing.md),
                  Text(item.question.prompt, style: UiText.h5),
                  const SizedBox(height: UiSpacing.xl),
                  Row(
                    children: [
                      answer == null
                          ? UiIcon.timer(color: color)
                          : correct
                          ? UiIcon.correct(color: color)
                          : UiIcon.incorrect(color: color),
                      const SizedBox(width: UiSpacing.sm),
                      Text(
                        answer == null
                            ? AppStrings.simulationNotAnswered
                            : correct
                            ? AppStrings.activityCorrect
                            : AppStrings.activityIncorrect,
                        style: UiText.h6.copyWith(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.lg),
                  Text(AppStrings.simulationYourAnswer, style: UiText.label),
                  Text(answer ?? AppStrings.simulationBlank, style: UiText.p),
                  const SizedBox(height: UiSpacing.lg),
                  Text(AppStrings.correctAnswer, style: UiText.label),
                  Text(item.question.correctAnswerForFeedback, style: UiText.p),
                  const SizedBox(height: UiSpacing.lg),
                  Text(AppStrings.answerExplanation, style: UiText.label),
                  Text(item.question.incorrectFeedback, style: UiText.p),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(UiSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: index > 0
                          ? () => setState(() => index--)
                          : null,
                      child: const Text(AppStrings.previous),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: index < session.questions.length - 1
                          ? () => setState(() => index++)
                          : null,
                      child: const Text(AppStrings.next),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
