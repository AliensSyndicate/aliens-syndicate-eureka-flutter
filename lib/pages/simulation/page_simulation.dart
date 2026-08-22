import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../app/components/app_button.dart';
import '../../app/components/app_skeleton.dart';
import '../../app/navigation/navigation_router.dart';
import '../../controllers/controller_simulation.dart';
import '../../enums/subject_type.dart';
import '../../l10n/app_strings.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import '../../services/service_registry.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';
import '../../ui/ui_spacing.dart';
import '../../ui/ui_text.dart';

class PageSimulation extends StatefulWidget {
  const PageSimulation({super.key});
  @override
  State<PageSimulation> createState() => _PageSimulationState();
}

class _PageSimulationState extends State<PageSimulation> {
  late final Future<List<SubjectContentManifest>> _subjects;
  final _selectedSubjects = <SubjectType>{};
  final _selectedLessonIds = <String>{};
  int _questionCount = 10;
  int _durationMinutes = 20;
  bool _starting = false;
  SimulationController? _savedController;

  @override
  void initState() {
    super.initState();
    _subjects = ServiceRegistry.content.loadSubjectsForYear(
      ServiceRegistry.user.loadCurrentUser().schoolYear,
    );
    final saved = ServiceRegistry.simulationRepository.loadActive();
    if (saved != null) {
      _savedController = SimulationController(
        repository: ServiceRegistry.simulationRepository,
        service: ServiceRegistry.simulation,
        session: saved,
      );
    }
  }

  bool get _isValid =>
      _selectedSubjects.isNotEmpty && _selectedLessonIds.isNotEmpty;

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<SubjectContentManifest>>(
        future: _subjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _SimulationSkeleton();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _SimulationMessage(
              message: AppStrings.contentUnavailable,
              onPressed: () => setState(() {}),
            );
          }
          final subjects = snapshot.data!;
          final lessons = _lessonsFor(subjects);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              UiSpacing.pageHorizontal,
              UiSpacing.pageVertical,
              UiSpacing.pageHorizontal,
              UiSpacing.xxxl,
            ),
            children: [
              const Text(AppStrings.simulation, style: UiText.h3),
              const SizedBox(height: UiSpacing.xs),
              const Text(AppStrings.simulationIntro, style: UiText.p),
              if (_savedController != null) ...[
                const SizedBox(height: UiSpacing.lg),
                AppButton(
                  label: AppStrings.simulationContinueSaved,
                  onPressed: _resumeSaved,
                ),
              ],
              const SizedBox(height: UiSpacing.xxl),
              _ConfigurationRow(
                label: AppStrings.subjectsTitle,
                value: _selectedSubjects.isEmpty
                    ? AppStrings.simulationSelectSubjects
                    : _selectedSubjects.map(AppStrings.subjectName).join(', '),
                onTap: () => _selectSubjects(subjects),
              ),
              _ConfigurationRow(
                label: AppStrings.simulationContents,
                value: _selectedLessonIds.isEmpty
                    ? AppStrings.simulationSelectContents
                    : AppStrings.selectedContents(_selectedLessonIds.length),
                onTap: _selectedSubjects.isEmpty
                    ? null
                    : () => _selectContents(lessons),
              ),
              _ConfigurationRow(
                label: AppStrings.simulationQuestions,
                value: '$_questionCount',
                onTap: _selectQuestionCount,
              ),
              _ConfigurationRow(
                label: AppStrings.simulationTime,
                value: '$_durationMinutes min',
                onTap: _selectDuration,
              ),
              if (_durationMinutes * 2 < _questionCount) ...[
                const SizedBox(height: UiSpacing.md),
                const Text(
                  AppStrings.simulationTightTime,
                  style: TextStyle(color: UiColor.warning),
                ),
              ],
              const SizedBox(height: UiSpacing.xxl),
              AppButton(
                label: AppStrings.startSimulation,
                isLoading: _starting,
                onPressed: _isValid && !_starting
                    ? () => _confirmStart(lessons)
                    : null,
              ),
            ],
          );
        },
      );

  List<Lesson> _lessonsFor(List<SubjectContentManifest> subjects) => subjects
      .where((subject) => _selectedSubjects.contains(subject.type))
      .expand(
        (subject) => subject.availableLessonsForYear(
          ServiceRegistry.user.loadCurrentUser().schoolYear,
        ),
      )
      .toList();

  Future<void> _selectSubjects(List<SubjectContentManifest> subjects) async {
    final draft = {..._selectedSubjects};
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.subjectsTitle,
      content: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: subjects.map((subject) {
            final selected = draft.contains(subject.type);
            return _SelectionTile(
              label: subject.title,
              selected: selected,
              color: UiColor.forSubject(subject.type),
              icon: _subjectIcon(subject.type),
              onTap: () => setSheetState(
                () => selected
                    ? draft.remove(subject.type)
                    : draft.add(subject.type),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        AppButton(
          label: AppStrings.finish,
          onPressed: () {
            setState(() {
              _selectedSubjects
                ..clear()
                ..addAll(draft);
              final validIds = _lessonsFor(subjects).map((item) => item.id);
              _selectedLessonIds.retainAll(validIds);
              if (_selectedLessonIds.isEmpty) {
                _selectedLessonIds.addAll(validIds);
              }
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Future<void> _selectContents(List<Lesson> lessons) async {
    final draft = {..._selectedLessonIds};
    await AppBottomSheet.show<void>(
      context,
      title: AppStrings.simulationContents,
      content: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SelectionTile(
              label: AppStrings.simulationAllContents,
              selected: draft.length == lessons.length,
              color: UiColor.accent,
              onTap: () => setSheetState(() {
                if (draft.length == lessons.length) {
                  draft.clear();
                } else {
                  draft
                    ..clear()
                    ..addAll(lessons.map((item) => item.id));
                }
              }),
            ),
            for (final subject in _selectedSubjects) ...[
              const SizedBox(height: UiSpacing.md),
              Text(AppStrings.subjectName(subject), style: UiText.h6),
              const SizedBox(height: UiSpacing.xs),
              for (final lesson in lessons.where(
                (item) => item.subject == subject,
              ))
                _SelectionTile(
                  label: lesson.title,
                  selected: draft.contains(lesson.id),
                  color: UiColor.forSubject(subject),
                  onTap: () => setSheetState(
                    () => draft.contains(lesson.id)
                        ? draft.remove(lesson.id)
                        : draft.add(lesson.id),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        AppButton(
          label: AppStrings.finish,
          onPressed: () {
            setState(
              () => _selectedLessonIds
                ..clear()
                ..addAll(draft),
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Future<void> _selectQuestionCount() => _selectPreset(
    title: AppStrings.simulationQuestions,
    values: const [10, 20, 30, 40, 50],
    selected: _questionCount,
    label: (value) => '$value questões',
    onSelected: (value) => setState(() => _questionCount = value),
  );

  Future<void> _selectDuration() => _selectPreset(
    title: AppStrings.simulationTime,
    values: const [10, 20, 30, 45, 60],
    selected: _durationMinutes,
    label: (value) => '$value min',
    onSelected: (value) => setState(() => _durationMinutes = value),
  );

  Future<void> _selectPreset({
    required String title,
    required List<int> values,
    required int selected,
    required String Function(int) label,
    required ValueChanged<int> onSelected,
  }) => AppBottomSheet.show<void>(
    context,
    title: title,
    content: Wrap(
      spacing: UiSpacing.xs,
      runSpacing: UiSpacing.xs,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(label(value)),
              selected: value == selected,
              onSelected: (_) {
                onSelected(value);
                Navigator.pop(context);
              },
            ),
          )
          .toList(),
    ),
  );

  Future<void> _confirmStart(List<Lesson> lessons) => AppBottomSheet.show<void>(
    context,
    title: AppStrings.startSimulation,
    content: Text(
      AppStrings.simulationConfirmation(
        _questionCount,
        _selectedSubjects.map(AppStrings.subjectName).join(' e '),
        _durationMinutes,
      ),
      style: UiText.p,
    ),
    actions: [
      AppButton(
        label: AppStrings.start,
        onPressed: () {
          Navigator.pop(context);
          _start(lessons);
        },
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(AppStrings.back),
      ),
    ],
  );

  Future<void> _start(List<Lesson> lessons) async {
    setState(() => _starting = true);
    try {
      final selected = lessons
          .where((item) => _selectedLessonIds.contains(item.id))
          .toList();
      final loaded = await Future.wait(
        selected.map(ServiceRegistry.content.loadActivity),
      );
      final questions = ServiceRegistry.simulation.buildQuestions(
        loaded,
        count: _questionCount,
      );
      if (!mounted) return;
      if (questions.isEmpty) {
        await _showUnavailable();
        return;
      }
      final controller = SimulationController(
        repository: ServiceRegistry.simulationRepository,
        service: ServiceRegistry.simulation,
      );
      await controller.start(questions, Duration(minutes: _durationMinutes));
      if (!mounted) return;
      await context.pushNamed(
        AppRoute.simulationQuestion,
        extra: SimulationRouteArguments(controller),
      );
    } on Object {
      if (mounted) await _showUnavailable();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _resumeSaved() async {
    final controller = _savedController!;
    if (controller.session.remainingAt(DateTime.now()) == Duration.zero) {
      final result = controller.result();
      await controller.complete();
      if (!mounted) return;
      context.pushNamed(
        AppRoute.simulationResult,
        extra: SimulationResultRouteArguments(
          controller: controller,
          result: result,
          expired: true,
        ),
      );
      return;
    }
    await context.pushNamed(
      AppRoute.simulationQuestion,
      extra: SimulationRouteArguments(controller),
    );
  }

  Future<void> _showUnavailable() => AppBottomSheet.show<void>(
    context,
    title: AppStrings.simulation,
    content: const Text(AppStrings.contentUnavailable),
    actions: [
      AppButton(
        label: AppStrings.finish,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

class _ConfigurationRow extends StatelessWidget {
  const _ConfigurationRow({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: UiSize.touchTarget + 24),
      padding: const EdgeInsets.symmetric(vertical: UiSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UiColor.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: UiText.label),
                const SizedBox(height: UiSpacing.xxs),
                Text(value, style: UiText.h6),
              ],
            ),
          ),
          UiIcon.next(
            color: onTap == null ? UiColor.textDisabled : UiColor.accent,
          ),
        ],
      ),
    ),
  );
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: UiSpacing.xs),
    child: Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: UiSize.touchTarget),
          padding: const EdgeInsets.all(UiSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .14) : UiColor.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : UiColor.outline),
          ),
          child: Row(
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: UiSpacing.sm)],
              Expanded(child: Text(label, style: UiText.p)),
              if (selected) UiIcon.check(color: color),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _subjectIcon(SubjectType subject) => switch (subject) {
  SubjectType.portuguese => UiIcon.subjectPortuguese(),
  SubjectType.mathematics => UiIcon.subjectMath(),
  SubjectType.science => UiIcon.subjectScience(),
  SubjectType.history => UiIcon.subjectHistory(),
  SubjectType.geography => UiIcon.subjectGeography(),
  _ => const SizedBox.square(dimension: UiSize.iconNavigation),
};

class _SimulationSkeleton extends StatelessWidget {
  const _SimulationSkeleton();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(UiSpacing.pageHorizontal),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeleton(height: 36, width: 150),
        SizedBox(height: UiSpacing.xxl),
        AppSkeleton(height: 72),
        SizedBox(height: UiSpacing.sm),
        AppSkeleton(height: 72),
        SizedBox(height: UiSpacing.sm),
        AppSkeleton(height: 72),
      ],
    ),
  );
}

class _SimulationMessage extends StatelessWidget {
  const _SimulationMessage({required this.message, required this.onPressed});
  final String message;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(UiSpacing.pageHorizontal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: UiText.p, textAlign: TextAlign.center),
          const SizedBox(height: UiSpacing.lg),
          AppButton(label: AppStrings.tryAgain, onPressed: onPressed),
        ],
      ),
    ),
  );
}
