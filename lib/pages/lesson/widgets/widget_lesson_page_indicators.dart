import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_motion.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

enum LessonPageIndicatorStatus {
  content,
  unanswered,
  correct,
  incorrect,
  summary,
  summaryDisabled,
}

class LessonPageIndicators extends StatelessWidget {
  const LessonPageIndicators({
    required this.currentPage,
    required this.statuses,
    required this.onSelected,
    super.key,
  });
  final int currentPage;
  final List<LessonPageIndicatorStatus> statuses;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (statuses.isEmpty) return const SizedBox.shrink();
      final availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : UiSize.touchTarget * (statuses.length + 1);
      final circleWidth = (availableWidth / statuses.length).clamp(
        0.0,
        UiSize.indicatorHeight,
      );
      final gapCount = statuses.length - 1;
      final maximumGap = gapCount == 0
          ? 0.0
          : (availableWidth - circleWidth * statuses.length) / gapCount;
      final gap = maximumGap.clamp(0.0, UiSpacing.sm);
      final selectedWidth =
          availableWidth - circleWidth * gapCount - gap * gapCount;
      final duration = MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : UiMotion.screenTransitionDuration;

      return Row(
        children: statuses.indexed
            .map((entry) {
              final index = entry.$1;
              final status = entry.$2;
              final selected = index == currentPage;
              final enabled =
                  status != LessonPageIndicatorStatus.summaryDisabled;
              final color = switch (status) {
                LessonPageIndicatorStatus.content => UiColor.success,
                LessonPageIndicatorStatus.correct => UiColor.success,
                LessonPageIndicatorStatus.incorrect => UiColor.error,
                LessonPageIndicatorStatus.unanswered => UiColor.outline,
                LessonPageIndicatorStatus.summary => UiColor.success,
                LessonPageIndicatorStatus.summaryDisabled => UiColor.outline,
              };
              final state = switch (status) {
                LessonPageIndicatorStatus.correct => 'respondida corretamente',
                LessonPageIndicatorStatus.incorrect =>
                  'respondida incorretamente',
                LessonPageIndicatorStatus.content => 'conteúdo',
                LessonPageIndicatorStatus.unanswered => 'ainda não respondida',
                LessonPageIndicatorStatus.summary => 'resumo disponível',
                LessonPageIndicatorStatus.summaryDisabled =>
                  'resumo indisponível, finalize as atividades',
              };
              return <Widget>[
                TweenAnimationBuilder<double>(
                  key: ValueKey('lesson-page-indicator-slot-$index'),
                  tween: Tween(end: selected ? selectedWidth : circleWidth),
                  duration: duration,
                  curve: UiMotion.screenTransitionCurve,
                  builder: (context, width, child) =>
                      SizedBox(width: width, child: child),
                  child: Semantics(
                    button: true,
                    enabled: enabled,
                    selected: selected,
                    label: 'Página ${index + 1} de ${statuses.length}, $state',
                    child: InkWell(
                      key: ValueKey('lesson-page-indicator-$index'),
                      onTap: enabled ? () => onSelected(index) : null,
                      borderRadius: BorderRadius.circular(UiRadius.pill),
                      child: AnimatedContainer(
                        duration: duration,
                        curve: UiMotion.screenTransitionCurve,
                        width: double.infinity,
                        height: circleWidth,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(UiRadius.pill),
                        ),
                      ),
                    ),
                  ),
                ),
                if (index < statuses.length - 1) SizedBox(width: gap),
              ];
            })
            .expand((items) => items)
            .toList(),
      );
    },
  );
}
