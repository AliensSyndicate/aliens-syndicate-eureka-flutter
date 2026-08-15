import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../controllers/controller_home.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';
import '../lesson/page_lesson.dart';
import '../subject/page_subject_lessons.dart';
import 'widgets/widget_continue_learning_card.dart';
import 'widgets/widget_subject_card.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});
  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final int schoolYear;
  late final Future<List<SubjectContentManifest>> subjects;

  @override
  void initState() {
    super.initState();
    schoolYear = ServiceRegistry.user.loadCurrentUser().schoolYear;
    subjects = HomeController(ServiceRegistry.content).loadSubjects(schoolYear);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<SubjectContentManifest>>(
        future: subjects,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          final savedProgress = ServiceRegistry.progress.load();
          SubjectContentManifest? lastSubject;
          Lesson? lastLesson;
          for (final subject in items) {
            for (final lesson in subject.lessonsForYear(schoolYear)) {
              if (lesson.id == savedProgress.lastLessonId) {
                lastSubject = subject;
                lastLesson = lesson;
              }
            }
          }
          // Fallback visual temporário: não altera o progresso persistido.
          if (lastLesson == null) {
            for (final subject in items) {
              if (subject.id != 'mathematics') continue;
              final lessons = subject.lessonsForYear(schoolYear);
              if (lessons.isNotEmpty) {
                lastSubject = subject;
                lastLesson = lessons.first;
              }
            }
          }
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.pageHorizontal,
              vertical: UiSpacing.pageVertical,
            ),
            children: [
              if (lastSubject != null && lastLesson != null) ...[
                Text(AppStrings.continueWhereStopped, style: UiText.h5),
                const SizedBox(height: UiSpacing.sm),
                ContinueLearningCard(
                  subject: lastSubject,
                  lesson: lastLesson,
                  progress: ServiceRegistry.progress.completionPercentage(
                    lastSubject.lessonsForYear(schoolYear),
                  ),
                  onTap: () => _continueLesson(lastLesson!),
                ),
                const SizedBox(height: UiSpacing.sectionSpacing),
              ],
              Text(AppStrings.subjectsTitle, style: UiText.h5),
              const SizedBox(height: UiSpacing.sm),
              const Text(AppStrings.journeySubtitle, style: UiText.p),
              const SizedBox(height: UiSpacing.sectionSpacing),
              ...items.map((subject) {
                final progress = ServiceRegistry.progress.completionPercentage(
                  subject.lessonsForYear(schoolYear),
                );
                return SubjectCard(
                  subject: subject,
                  progress: progress,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PageSubjectLessons(
                          subject: subject,
                          schoolYear: schoolYear,
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                );
              }),
            ],
          );
        },
      );

  Future<void> _continueLesson(Lesson lesson) async {
    final activity = await ServiceRegistry.content.loadActivity(lesson);
    if (!mounted) return;
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
    if (mounted) setState(() {});
  }
}
