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
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/widget_curriculum_year_section.dart';
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
    final years = [...subject.schoolYearsForYear(schoolYear)]
      ..sort((a, b) => a.order.compareTo(b.order));
    final progress = ServiceRegistry.progress.load();
    final completed = progress.completedLessonIds.toSet();
    final color = UiColor.forSubject(subject.type);
    final allLessons = subject.lessonsForYear(schoolYear);
    final completedCount =
        allLessons.where((l) => completed.contains(l.id)).length;
    final lastCompletedLesson = allLessons
        .where((lesson) => completed.contains(lesson.id))
        .lastOrNull;

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
            if (years.isEmpty)
              const Padding(
                padding: EdgeInsets.all(UiSpacing.sectionSpacing),
                child: Text(
                  AppStrings.emptyResults,
                  textAlign: TextAlign.center,
                ),
              ),
            ...years.map(
              (year) => CurriculumYearSection(
                year: year,
                color: color,
                completedLessonIds: completed,
                onLessonTap: (lesson) => _openLesson(context, lesson),
              ),
            ),
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
