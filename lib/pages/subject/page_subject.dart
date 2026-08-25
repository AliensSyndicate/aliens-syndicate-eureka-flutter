import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
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
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import 'widgets/widget_lesson_progress_card.dart';
import 'widgets/widget_subject_sheet_header.dart';

Future<void> showSubjectSheet(
  BuildContext context, {
  required SubjectContentManifest subject,
  required int schoolYear,
}) async {
  final progress = ServiceRegistry.progress.load();
  final lessons = subject.lessonsForYear(schoolYear);
  final completed = ServiceRegistry.progress.completedLessonIdsFor(lessons);
  final completedCount = lessons
      .where((lesson) => completed.contains(lesson.id))
      .length;
  final lesson = await AppBottomSheet.show<Lesson>(
    context,
    title: subject.title,
    titleColor: UiColor.forSubject(subject.type),
    isDismissible: false,
    enableDrag: false,
    header: Builder(
      builder: (sheetContext) => SubjectSheetHeader(
        title: subject.title,
        color: UiColor.forSubject(subject.type),
        subject: subject.type,
        schoolYear: schoolYear,
        xp: progress.xp,
        completedLessons: completedCount,
        totalLessons: lessons.length,
        onClose: () => Navigator.of(sheetContext).pop(),
        onReport: () => _showSubjectReport(sheetContext, subject),
      ),
    ),
    content: SubjectSheet(subject: subject, schoolYear: schoolYear),
  );
  if (lesson == null || !context.mounted) return;

  await context.pushNamed(
    AppRoute.lessonLoading,
    extra: LessonLoadingRouteArguments(
      lesson: lesson,
      mode: LearningMode.journey,
    ),
  );
}

Future<void> _showSubjectReport(
  BuildContext context,
  SubjectContentManifest subject,
) => AppReportBottomSheet.show(
  context,
  subjectId: subject.type.name,
  lessonTitle: subject.title,
  reportContext: ReportContext.subject,
);

class SubjectSheet extends StatelessWidget {
  const SubjectSheet({
    required this.subject,
    required this.schoolYear,
    super.key,
  });
  final SubjectContentManifest subject;
  final int schoolYear;

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();
    final color = UiColor.forSubject(subject.type);
    final allLessons = subject.lessonsForYear(schoolYear);
    final completed = ServiceRegistry.progress.completedLessonIdsFor(
      allLessons,
    );
    final completedCount = allLessons
        .where((l) => completed.contains(l.id))
        .length;
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
          final isCurrentSession =
              session.activityVersion == lesson.activityVersion;
          if (isCurrentSession &&
              (session.results.isNotEmpty || session.currentPage > 0)) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (continueLesson != null) ...[
          _LessonSection(
            title: AppStrings.continueTitle,
            featured: true,
            lessons: [continueLesson],
            allLessons: allLessons,
            completed: completed,
            color: color,
            onLessonTap: (lesson) => Navigator.of(context).pop(lesson),
          ),
          const SizedBox(height: UiSpacing.sectionSpacing),
        ],
        if (allLessons.isEmpty)
          Padding(
            padding: const EdgeInsets.all(UiSpacing.sectionSpacing),
            child: Text(AppStrings.emptyResults, textAlign: TextAlign.center),
          )
        else ...[
          _LessonSection(
            title: AppStrings.lessonsTitle,
            count: allLessons.length,
            lessons: allLessons,
            allLessons: allLessons,
            completed: completed,
            color: color,
            onLessonTap: (lesson) => Navigator.of(context).pop(lesson),
          ),
        ],
      ],
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
    this.featured = false,
  });

  final String title;
  final int? count;
  final bool featured;
  final List<Lesson> lessons;
  final List<Lesson> allLessons;
  final Set<String> completed;
  final Color color;
  final ValueChanged<Lesson> onLessonTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!featured) ...[
        Text(
          count != null ? AppStrings.lessonsCountHeader(count!) : title,
          style: UiText.h5.copyWith(color: UiColor.textPrimary),
        ),
        const SizedBox(height: UiSpacing.sm),
      ],
      Column(
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
              featured: featured,
              eyebrow: featured ? title : null,
              onTap: () => onLessonTap(lesson),
            ),
            if (!featured && sectionIndex < lessons.length - 1)
              const Divider(
                height: 56.0,
                thickness: UiCard.borderWidth,
                color: UiColor.outline,
              ),
          ];
        }).toList(),
      ),
    ],
  );
}
