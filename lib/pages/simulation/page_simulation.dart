import 'package:flutter/material.dart';
import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_card.dart';
import '../../enums/learning_mode.dart';
import '../../l10n/app_strings.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_spacing.dart';
import '../lesson/page_lesson.dart';

class PageSimulation extends StatefulWidget {
  const PageSimulation({super.key});
  @override
  State<PageSimulation> createState() => _PageSimulationState();
}

class _PageSimulationState extends State<PageSimulation> {
  final selectedIds = <String>{};
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
        final items = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpacing.pageHorizontal,
            vertical: UiSpacing.pageVertical,
          ),
          children: [
            Text(
              AppStrings.simulation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: UiSpacing.lg),
            ...items.map(
              (lesson) => AppCard(
                onTap: () => _toggle(lesson.id),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selectedIds.contains(lesson.id),
                  onChanged: (_) => _toggle(lesson.id),
                  title: Text(lesson.title),
                  subtitle: const Text(AppStrings.selectToReview),
                ),
              ),
            ),
            const SizedBox(height: UiSpacing.md),
            AppButton(
              label: AppStrings.startSimulation,
              onPressed: () => _start(items),
            ),
          ],
        );
      },
    );
  }

  void _toggle(String id) => setState(
    () =>
        selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id),
  );

  Future<void> _start(List<Lesson> lessons) async {
    final selected = lessons
        .where((lesson) => selectedIds.contains(lesson.id))
        .toList();
    if (selected.isEmpty) {
      await AppBottomSheet.show<void>(
        context,
        title: AppStrings.simulation,
        content: const Text(AppStrings.selectAtLeastOne),
        actions: [
          AppButton(
            label: AppStrings.finish,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }
    final simulation = Lesson(
      id: 'simulation',
      title: AppStrings.simulation,
      summary: AppStrings.noXpOutsideJourney,
      subject: selected.first.subject,
      questions: selected.expand((lesson) => lesson.questions).toList(),
    );
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PageLesson(lesson: simulation, mode: LearningMode.simulation),
        ),
      );
    }
  }
}
