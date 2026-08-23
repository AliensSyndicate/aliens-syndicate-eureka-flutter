import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../services/service_registry.dart';
import '../../../services/service_scoring.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_spacing.dart';
import '../../../ui/ui_text.dart';

class LessonProgressCard extends StatelessWidget {
  const LessonProgressCard({
    required this.lesson,
    required this.color,
    required this.lessonIndex,
    required this.totalLessons,
    required this.isCompleted,
    required this.onTap,
    super.key,
  });

  final Lesson lesson;
  final Color color;
  final int lessonIndex;
  final int totalLessons;
  final bool isCompleted;
  final VoidCallback onTap;

  static const double _progressBarHeight = UiCard.progressTagHeight;
  static const double _trackOpacity = 0.18;

  int get _difficultyLevel {
    if (lesson.questions.isEmpty) return 1;
    final maxDiff = lesson.questions
        .map((q) => q.difficulty)
        .fold<int>(1, math.max);
    return maxDiff.clamp(1, 5);
  }

  String get _xpText {
    final session = ServiceRegistry.progress.loadLessonSession(lesson.id);
    final scoring = ScoringService();
    final hasStarted =
        session.currentPage > 0 ||
        session.questionIds.isNotEmpty ||
        session.answers.isNotEmpty ||
        session.results.isNotEmpty ||
        session.completed ||
        isCompleted;

    if (isCompleted) {
      final result = ServiceRegistry.progress.loadLatestActivityResult(
        lesson.id,
      );
      final earned =
          result?.earnedXp ??
          scoring.calculateJourneyXpFromResults(session.results.values);
      return AppStrings.earnedXpGain(earned);
    }

    if (hasStarted) {
      final earned = scoring.calculateJourneyXpFromResults(
        session.results.values,
      );
      return AppStrings.earnedXpGain(earned);
    }

    return AppStrings.earnUpToXp(ScoringService.maximumJourneyLessonXp);
  }

  double get _progress {
    if (isCompleted) return 1.0;
    final session = ServiceRegistry.progress.loadLessonSession(lesson.id);
    if (session.completed) return 1.0;
    final total = session.questionIds.isNotEmpty
        ? session.questionIds.length
        : (lesson.practiceQuestions.isNotEmpty
              ? (lesson.practiceQuestions.length > 5
                    ? 5
                    : lesson.practiceQuestions.length)
              : (lesson.questions.isNotEmpty
                    ? (lesson.questions.length > 5
                          ? 5
                          : lesson.questions.length)
                    : 1));
    final answered = session.results.length;
    if (total == 0 || answered == 0) return 0.0;
    return (answered / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;

    return Semantics(
      button: true,
      label: AppStrings.lessonSemantics(lesson.title, isCompleted),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(lesson.title, style: UiText.p, softWrap: true),
                const SizedBox(height: UiSpacing.xxs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.difficultyLevelName(_difficultyLevel),
                      style: UiText.small.copyWith(
                        color: UiColor.forDifficulty(_difficultyLevel),
                      ),
                    ),
                    Text(
                      _xpText,
                      style: UiText.small.copyWith(color: UiColor.xp),
                    ),
                  ],
                ),
                const SizedBox(height: UiSpacing.xs),
                SizedBox(
                  height: _progressBarHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(UiRadius.pill),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: color.withValues(alpha: _trackOpacity),
                          ),
                        ),
                        if (progress > 0)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(
                                    UiRadius.pill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Text(
                            AppStrings.percent((progress * 100).round()),
                            textAlign: TextAlign.center,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: UiText.p.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1,
                              color: progress > 0.4 ? Colors.white : color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
