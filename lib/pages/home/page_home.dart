import 'package:flutter/material.dart';
import '../../controllers/controller_home.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import 'widgets/widget_lesson_card.dart';
import '../lesson/page_lesson.dart';
import '../../models/model_lesson.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});
  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late final Future<List<Lesson>> lessons;
  @override
  void initState() {
    super.initState();
    lessons = HomeController(ServiceRegistry.content).loadJourney();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lesson>>(
      future: lessons,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(UiSpacing.lg),
          children: [
            Text(
              AppStrings.greeting,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: UiSpacing.sm),
            const Text(AppStrings.journeySubtitle),
            const SizedBox(height: UiSpacing.lg),
            if (items.isEmpty)
              const Text(AppStrings.emptyResults, textAlign: TextAlign.center),
            ...items.map(
              (lesson) => LessonCard(
                lesson: lesson,
                onTap: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PageLesson(
                        lesson: lesson,
                        mode: LearningMode.journey,
                      ),
                    ),
                  );
                  if (mounted) setState(() {});
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
