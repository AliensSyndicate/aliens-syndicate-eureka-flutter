import 'package:flutter/material.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import '../home/widgets/widget_lesson_card.dart';
import '../lesson/page_lesson.dart';

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
    final lessons = subject.lessonsForYear(schoolYear);
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          children: [
            if (lessons.isEmpty)
              const Padding(
                padding: EdgeInsets.all(UiSpacing.sectionSpacing),
                child: Text(
                  AppStrings.emptyResults,
                  textAlign: TextAlign.center,
                ),
              ),
            ...lessons.map(
              (lesson) => LessonCard(
                lesson: lesson,
                onTap: () async {
                  final activity = await ServiceRegistry.content.loadActivity(
                    lesson,
                  );
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
                      builder: (_) => PageLesson(
                        lesson: activity,
                        mode: LearningMode.journey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
