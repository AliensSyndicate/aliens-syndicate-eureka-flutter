import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_spacing.dart';
import '../lesson/page_lesson.dart';
import 'widgets/widget_curriculum_year_section.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PageLesson(lesson: activity, mode: LearningMode.journey),
      ),
    );
  }
}
