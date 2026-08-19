import 'package:eureka/app/components/subject_card.dart';
import 'package:eureka/pages/auth/page_auth.dart';
import 'package:eureka/pages/home/widgets/widget_login.dart';
import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_home_bar.dart';
import '../../config/config_product.dart';
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
import 'widgets/widget_home_cards_skeleton.dart';
import 'widgets/widget_recommendation_card.dart';

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
    schoolYear = ProductConfig.v1SchoolYear;
    subjects = HomeController(ServiceRegistry.content).loadSubjects(schoolYear);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ServiceRegistry.progress.load();

    return Column(
      children: [
        AppHomeBar(
          xp: progress.xp,
          seriesLabel: '1 EM',
          onXpTap: () =>
              _showValue(AppStrings.xpLabel, AppStrings.xpValue(progress.xp)),
          onSeriesTap: () => _showValue(
            AppStrings.levelLabel,
            AppStrings.levelValue(progress.level),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<SubjectContentManifest>>(
            future: subjects,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const HomeCardsSkeleton();
              }
              final items = snapshot.data!;
              final savedProgress = ServiceRegistry.progress.load();
              SubjectContentManifest? lastSubject;
              Lesson? lastLesson;
              for (final subject in items) {
                for (final lesson in subject.availableLessonsForYear(
                  schoolYear,
                )) {
                  if (lesson.id == savedProgress.lastLessonId) {
                    lastSubject = subject;
                    lastLesson = lesson;
                  }
                }
              }
              if (lastLesson == null) {
                for (final subject in items) {
                  if (subject.id != 'mathematics') continue;
                  final lessons = subject.availableLessonsForYear(schoolYear);
                  if (lessons.isNotEmpty) {
                    lastSubject = subject;
                    lastLesson = lessons.first;
                  }
                }
              }
              final recommendation = ServiceRegistry.recommendation.recommend(
                items,
                schoolYear,
                ServiceRegistry.progress.loadDifficultyScores(),
              );
              return ListView(
                padding: EdgeInsets.only(
                  left: UiSpacing.pageHorizontal,
                  right: UiSpacing.pageHorizontal,
                  top: UiSpacing.sm,
                  bottom: UiSpacing.pageVertical,
                ),
                children: [
                  if (true) ...[
                    LoginCard(
                      onTap: () =>
                          MaterialPageRoute(builder: (_) => PageAuth()),
                    ),
                    const SizedBox(height: UiSpacing.sectionSpacing),
                  ],
                  if (recommendation != null) ...[
                    Text(AppStrings.recommendedForYou, style: UiText.h4),
                    const SizedBox(height: UiSpacing.sm),
                    RecommendationCard(
                      recommendation: recommendation,
                      onTap: () => _continueLesson(recommendation.lesson),
                    ),
                    const SizedBox(height: UiSpacing.sectionSpacing),
                  ],
                  if (lastSubject != null && lastLesson != null) ...[
                    Text(AppStrings.continueWhereStopped, style: UiText.h4),
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
                  Text(AppStrings.subjectsTitle, style: UiText.h4),
                  const SizedBox(height: UiSpacing.sm),
                  ...items.map((subject) {
                    final progressPercentage = ServiceRegistry.progress
                        .completionPercentage(
                          subject.lessonsForYear(schoolYear),
                        );
                    return SubjectCard(
                      subject: subject,
                      progress: progressPercentage,
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
          ),
        ),
      ],
    );
  }

  Future<void> _showValue(String title, String value) =>
      AppBottomSheet.show<void>(
        context,
        title: title,
        content: Text(value),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
