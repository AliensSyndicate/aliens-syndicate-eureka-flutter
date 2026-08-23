import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_report_bottom_sheet.dart';
import '../../app/navigation/navigation_router.dart';
import '../../enums/learning_mode.dart';
import '../../enums/report_context.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_card.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_lesson_progress_card.dart';
import 'widgets/widget_subject_lessons_app_bar.dart';

class PageSubjectLessons extends StatelessWidget {
  const PageSubjectLessons({
    required this.subject,
    required this.schoolYear,
    super.key,
  });
  final SubjectContentManifest subject;
  final int schoolYear;

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();
    final completed = progress.completedLessonIds.toSet();
    final color = UiColor.forSubject(subject.type);
    final allLessons = subject.lessonsForYear(schoolYear);
    final completedCount = allLessons
        .where((l) => completed.contains(l.id))
        .length;
    final lastCompletedLesson = allLessons
        .where((lesson) => completed.contains(lesson.id))
        .lastOrNull;

    Lesson? continueLesson;
    if (progress.lastLessonId != null) {
      final match = allLessons
          .where((l) => l.id == progress.lastLessonId)
          .firstOrNull;
      if (match != null && !completed.contains(match.id)) {
        continueLesson = match;
      }
    }
    if (continueLesson == null) {
      for (final lesson in allLessons) {
        if (!completed.contains(lesson.id)) {
          final session = ServiceRegistry.progress.loadLessonSession(lesson.id);
          if (session.results.isNotEmpty || session.currentPage > 0) {
            continueLesson = lesson;
            break;
          }
        }
      }
    }
    if (continueLesson == null &&
        completedCount > 0 &&
        completedCount < allLessons.length) {
      continueLesson = allLessons
          .where((l) => !completed.contains(l.id))
          .firstOrNull;
    }

    return Scaffold(
      appBar: SubjectLessonsAppBar(
        title: subject.title,
        color: color,
        subject: subject.type,
        schoolYear: schoolYear,
        completedLessons: completedCount,
        totalLessons: allLessons.length,
        xp: progress.xp,
        lastCompletedLesson: lastCompletedLesson,
        onBack: context.pop,
        onReport: () => _showReportError(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          children: [
            if (continueLesson != null) ...[
              const SizedBox(height: UiSpacing.md),
              _LessonSection(
                title: AppStrings.continueTitle,
                lessons: [continueLesson],
                allLessons: allLessons,
                completed: completed,
                color: color,
                onLessonTap: (lesson) => _openLesson(context, lesson),
              ),
              const SizedBox(height: UiSpacing.sectionSpacing),
            ],
            if (allLessons.isEmpty)
              Padding(
                padding: const EdgeInsets.all(UiSpacing.sectionSpacing),
                child: Text(
                  AppStrings.emptyResults,
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              _LessonSection(
                title: AppStrings.lessonsTitle,
                count: allLessons.length,
                lessons: allLessons,
                allLessons: allLessons,
                completed: completed,
                color: color,
                onLessonTap: (lesson) => _openLesson(context, lesson),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showReportError(BuildContext context) =>
      AppReportBottomSheet.show(
        context,
        subjectId: subject.type.name,
        lessonTitle: subject.title,
        reportContext: ReportContext.subject,
      );

  Future<void> _openLesson(BuildContext context, Lesson lesson) async {
    await context.pushNamed(
      AppRoute.lessonLoading,
      extra: LessonLoadingRouteArguments(
        lesson: lesson,
        mode: LearningMode.journey,
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.title,
    required this.lessons,
    required this.allLessons,
    required this.completed,
    required this.color,
    required this.onLessonTap,
    this.count,
  });

  final String title;
  final int? count;
  final List<Lesson> lessons;
  final List<Lesson> allLessons;
  final Set<String> completed;
  final Color color;
  final ValueChanged<Lesson> onLessonTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Text(title, style: UiText.h3.copyWith(color: UiColor.textPrimary)),
          if (count != null) ...[
            const SizedBox(width: UiSpacing.xs),
            Text(
              '$count',
              style: UiText.h3.copyWith(color: UiColor.textSecondary),
            ),
          ],
        ],
      ),
      const SizedBox(height: UiSpacing.sm),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UiRadius.card),
          border: Border.all(color: UiColor.outline, width: UiCard.borderWidth),
        ),
        child: Column(
          children: lessons.indexed.expand((entry) {
            final (sectionIndex, lesson) = entry;
            final lessonIndex = allLessons.indexWhere(
              (item) => item.id == lesson.id,
            );
            return [
              LessonProgressCard(
                key: ValueKey('$title-${lesson.id}'),
                lesson: lesson,
                color: color,
                lessonIndex: lessonIndex < 0 ? sectionIndex : lessonIndex,
                totalLessons: allLessons.length,
                isCompleted: completed.contains(lesson.id),
                onTap: () => onLessonTap(lesson),
              ),
              if (sectionIndex < lessons.length - 1)
                const Divider(
                  height: UiCard.borderWidth,
                  thickness: UiCard.borderWidth,
                  indent: UiSpacing.lg,
                  endIndent: UiSpacing.lg,
                  color: UiColor.outline,
                ),
            ];
          }).toList(),
        ),
      ),
    ],
  );
}
