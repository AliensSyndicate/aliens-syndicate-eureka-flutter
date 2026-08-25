import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../models/model_lesson.dart';
import '../../../models/model_lesson_session.dart';
import '../../../services/service_registry.dart';
import '../../../services/service_scoring.dart';
import '../../../ui/ui_card.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_gradient.dart';
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
    this.featured = false,
    this.eyebrow,
    super.key,
  });

  final Lesson lesson;
  final Color color;
  final int lessonIndex;
  final int totalLessons;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool featured;
  final String? eyebrow;

  static const double _progressBarHeight = UiCard.progressTagHeight / 2;
  static const double _trackOpacity = 0.18;

  LessonSession get _session {
    final session = ServiceRegistry.progress.loadLessonSession(lesson.id);
    return session.activityVersion == lesson.activityVersion
        ? session
        : const LessonSession();
  }

  int get _difficultyLevel {
    if (lesson.questions.isEmpty) return 1;
    final maxDiff = lesson.questions
        .map((q) => q.difficulty)
        .fold<int>(1, math.max);
    return maxDiff.clamp(1, 5);
  }

  String get _xpText {
    final session = _session;
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

    return AppStrings.earnUpToXp(
      scoring.maximumJourneyXpForQuestionCount(lesson.practiceQuestions.length),
    );
  }

  double get _progress {
    if (isCompleted) return 1.0;
    final session = _session;
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
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: featured ? UiSpacing.md : 0,
        vertical: featured ? UiSpacing.lg : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (featured && eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: UiText.small.copyWith(
                color: UiColor.textPrimary.withValues(alpha: .82),
              ),
            ),
            const SizedBox(height: UiSpacing.xxs),
          ],
          Text(
            AppStrings.lessonNumberTitle(lessonIndex + 1, lesson.title),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiText.p,
            softWrap: true,
          ),
          const SizedBox(height: UiSpacing.xs),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiSpacing.xs,
                  vertical: UiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: featured
                      ? UiColor.background.withValues(alpha: .28)
                      : UiColor.forDifficulty(
                          _difficultyLevel,
                        ).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(UiRadius.sm),
                ),
                child: Text(
                  AppStrings.difficultyLevelName(_difficultyLevel),
                  style: UiText.small.copyWith(
                    color: featured
                        ? UiColor.textPrimary
                        : UiColor.forDifficulty(_difficultyLevel),
                  ),
                ),
              ),
              const Spacer(),
              Text(_xpText, style: UiText.small.copyWith(color: UiColor.xp)),
            ],
          ),
          const SizedBox(height: UiSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: _progressBarHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(UiRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: featured
                          ? UiColor.background.withValues(alpha: .28)
                          : color.withValues(alpha: _trackOpacity),
                      color: featured ? UiColor.textPrimary : color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: UiSpacing.sm),
              Text(
                AppStrings.percent((progress * 100).round()),
                style: UiText.small.copyWith(
                  color: featured ? UiColor.textPrimary : color,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiRadius.card),
        child: content,
      ),
    );

    return Semantics(
      button: true,
      label: AppStrings.lessonSemantics(lesson.title, isCompleted),
      child: featured
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: UiGradient.forSubject(lesson.subject),
                borderRadius: BorderRadius.circular(UiRadius.card),
                border: Border.all(
                  color: UiColor.textPrimary.withValues(alpha: .18),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiRadius.card),
                child: card,
              ),
            )
          : card,
    );
  }
}
