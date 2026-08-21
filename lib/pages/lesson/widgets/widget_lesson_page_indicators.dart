import 'package:flutter/material.dart';

import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_spacing.dart';

enum LessonPageIndicatorStatus { content, unanswered, correct, incorrect }

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
  Widget build(BuildContext context) => Row(
    children: statuses.indexed.map((entry) {
      final index = entry.$1;
      final status = entry.$2;
      final selected = index == currentPage;
      final color = selected
          ? UiColor.accent
          : switch (status) {
              LessonPageIndicatorStatus.correct => UiColor.success,
              LessonPageIndicatorStatus.incorrect => UiColor.error,
              LessonPageIndicatorStatus.content => UiColor.textSecondary,
              LessonPageIndicatorStatus.unanswered => UiColor.outline,
            };
      final state = switch (status) {
        LessonPageIndicatorStatus.correct => 'respondida corretamente',
        LessonPageIndicatorStatus.incorrect => 'respondida incorretamente',
        LessonPageIndicatorStatus.content => 'conteúdo',
        LessonPageIndicatorStatus.unanswered => 'ainda não respondida',
      };
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: index == statuses.length - 1 ? 0 : UiSpacing.xxs,
          ),
          child: Semantics(
            button: true,
            selected: selected,
            label: 'Página ${index + 1} de ${statuses.length}, $state',
            child: InkWell(
              key: ValueKey('lesson-page-indicator-$index'),
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(UiRadius.pill),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: UiSize.indicatorHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(UiRadius.pill),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}
