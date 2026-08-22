import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_simulation.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_simulation.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class PageSimulationResult extends StatelessWidget {
  const PageSimulationResult({
    required this.controller,
    required this.result,
    this.expired = false,
    super.key,
  });
  final SimulationController controller;
  final SimulationResult result;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final percent = (result.score * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.simulationResult)),
      body: ListView(
        padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
        children: [
          if (expired) ...[
            const Text(AppStrings.simulationTimeEnded, style: UiText.label),
            const SizedBox(height: UiSpacing.sm),
          ],
          Text('$percent%', style: UiText.h1),
          const SizedBox(height: UiSpacing.xs),
          Text(_resultMessage(percent), style: UiText.h5),
          const SizedBox(height: UiSpacing.xl),
          Wrap(
            spacing: UiSpacing.md,
            runSpacing: UiSpacing.sm,
            children: [
              _Metric('${result.correctAnswers}', AppStrings.simulationCorrect),
              _Metric(
                '${result.incorrectAnswers}',
                AppStrings.simulationIncorrect,
              ),
              _Metric(
                '${result.unansweredQuestions}',
                AppStrings.simulationBlank,
              ),
              _Metric(
                _minutes(result.durationUsed),
                AppStrings.simulationUsedTime,
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.xxl),
          const Text(AppStrings.simulationBySubject, style: UiText.h5),
          const SizedBox(height: UiSpacing.sm),
          ...result.bySubject.map(_BreakdownRow.new),
          const SizedBox(height: UiSpacing.xl),
          const Text(AppStrings.simulationByContent, style: UiText.h5),
          const SizedBox(height: UiSpacing.sm),
          ...result.byContent.map(_BreakdownRow.new),
          if (result.strongTopics.isNotEmpty) ...[
            const SizedBox(height: UiSpacing.xl),
            Text(
              AppStrings.simulationStrength(result.strongTopics.first),
              style: UiText.p.copyWith(color: UiColor.success),
            ),
          ],
          if (result.reviewTopics.isNotEmpty) ...[
            const SizedBox(height: UiSpacing.sm),
            Text(
              AppStrings.simulationImprove(result.reviewTopics.first),
              style: UiText.p.copyWith(color: UiColor.warning),
            ),
          ],
          const SizedBox(height: UiSpacing.xxl),
          AppButton(
            label: AppStrings.simulationReviewAnswers,
            onPressed: () => context.pushNamed(
              AppRoute.simulationReview,
              extra: SimulationRouteArguments(controller),
            ),
          ),
          const SizedBox(height: UiSpacing.sm),
          TextButton(
            onPressed: () => context.goNamed(AppRoute.simulation),
            child: const Text(AppStrings.simulationAnother),
          ),
        ],
      ),
    );
  }

  static String _resultMessage(int percent) => percent >= 90
      ? AppStrings.simulationExcellent
      : percent >= 70
      ? AppStrings.simulationWellDone
      : AppStrings.simulationAlmostThere;

  static String _minutes(Duration duration) => '${duration.inMinutes} min';
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 126,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: UiText.h4),
        Text(label, style: UiText.label),
      ],
    ),
  );
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(this.item);
  final SimulationBreakdown item;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(item.label, style: UiText.p)),
        Text(
          '${item.correct}/${item.total} · ${(item.score * 100).round()}%',
          style: UiText.label,
        ),
      ],
    ),
  );
}
