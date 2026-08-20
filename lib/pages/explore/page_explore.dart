import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/navigation/navigation_router.dart';
import '../../app/components/app_text_field.dart';
import '../../l10n/app_strings.dart';
import '../../services/service_registry.dart';
import '../../enums/learning_mode.dart';
import '../../ui/ui_spacing.dart';
import '../home/widgets/widget_lesson_card.dart';
import '../../models/model_lesson.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';

class PageExplore extends StatefulWidget {
  const PageExplore({super.key});
  @override
  State<PageExplore> createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  String query = '';
  late final Future<List<Lesson>> lessons;
  @override
  void initState() {
    super.initState();
    lessons = ServiceRegistry.content.loadJourneyLessons();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lesson>>(
      future: lessons,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snapshot.data!;
        final normalized = query.trim().toLowerCase();
        final results = normalized.isEmpty
            ? all
            : all
                  .where(
                    (lesson) => '${lesson.title} ${lesson.summary}'
                        .toLowerCase()
                        .contains(normalized),
                  )
                  .toList();
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          children: [
            Text(
              AppStrings.explore,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: UiSpacing.md),
            AppTextField(
              hint: AppStrings.exploreHint,
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: UiSpacing.md),
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(UiSpacing.lg),
                child: Text(
                  AppStrings.emptyResults,
                  textAlign: TextAlign.center,
                ),
              ),
            ...results.map(
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
                  await context.pushNamed(
                    AppRoute.lesson,
                    extra: LessonRouteArguments(
                      lesson: activity,
                      mode: LearningMode.explore,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
