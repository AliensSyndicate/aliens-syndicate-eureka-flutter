import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/navigation/navigation_router.dart';
import '../../enums/learning_mode.dart';
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
    final completed = ServiceRegistry.progress
        .load()
        .completedLessonIds
        .toSet();
    final color = UiColor.forSubject(subject.type);
    final allLessons = subject.lessons;
    final completedCount = allLessons
        .where((lesson) => completed.contains(lesson.id))
        .length;
    return Scaffold(
      appBar: SubjectLessonsAppBar(
        title: subject.title,
        color: color,
        subject: subject.type,
        completedLessons: completedCount,
        totalLessons: allLessons.length,
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
      AppBottomSheet.show<void>(
        context,
        title: AppStrings.reportError,
        content: const Text(AppStrings.reportErrorUnavailable),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  Future<void> _openLesson(BuildContext context, Lesson lesson) async {
    final activity = await ServiceRegistry.content.loadActivity(lesson);
    if (!context.mounted) return;
    if (activity.questions.isEmpty) {
      await AppBottomSheet.show<void>(
        context,
        title: lesson.title,
        content: const Text(AppStrings.contentUnavailable),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }
    await context.pushNamed(
      AppRoute.lesson,
      extra: LessonRouteArguments(lesson: activity, mode: LearningMode.journey),
    );
  }
}
